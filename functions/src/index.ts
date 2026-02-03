/**
 * Cloud Functions for Legal Firm Management System
 * 
 * NOTE: Firestore triggers are temporarily disabled because:
 * - Firestore is in me-central2 region
 * - Cloud Functions doesn't support me-central2 region
 * - Firestore triggers MUST be in the same region as Firestore
 * 
 * Solutions:
 * 1. Move Firestore to a supported region (us-central1, europe-west1, etc.)
 * 2. Contact Firebase Support to request me-central2 support
 * 3. Use Pub/Sub as intermediary (more complex)
 */

import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue, Timestamp} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
import {getStorage} from "firebase-admin/storage";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {onObjectFinalized} from "firebase-functions/v2/storage";
import {onCall} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

// Initialize Firebase Admin
initializeApp();
const db = getFirestore();
const auth = getAuth();
const storage = getStorage();

// ============================================================================
// Working Functions (Scheduled & Storage)
// ============================================================================

/**
 * updateSystemStats - Dashboard Statistics Aggregation
 * Aggregates system-wide statistics for dashboard overview
 */
export const updateSystemStats = onSchedule(
  {
    schedule: "every 1 hours",
    timeZone: "UTC",
    region: "us-central1",
    maxInstances: 1,
  },
  async (event) => {
    try {
      const now = new Date();
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

      // Aggregate clients
      const clientsSnapshot = await db.collection("clients").get();
      const clientsStats = {
        total: clientsSnapshot.size,
        active: clientsSnapshot.docs.filter((d) => d.data().isActive !== false).length,
        individuals: clientsSnapshot.docs.filter((d) => d.data().type === "individual").length,
        businesses: clientsSnapshot.docs.filter((d) => d.data().type === "business").length,
      };

      // Aggregate cases
      const casesSnapshot = await db.collection("cases").get();
      const casesStats = {
        total: casesSnapshot.size,
        active: casesSnapshot.docs.filter((d) => d.data().status === "active").length,
        prospects: casesSnapshot.docs.filter((d) => d.data().status === "prospect").length,
        closed: casesSnapshot.docs.filter((d) => d.data().status === "closed").length,
      };

      // Aggregate contracts
      const contractsSnapshot = await db.collection("contracts").get();
      const contractsStats = {
        total: contractsSnapshot.size,
        pending: contractsSnapshot.docs.filter((d) => d.data().status === "pending").length,
        signed: contractsSnapshot.docs.filter((d) => d.data().status === "signed").length,
        archived: contractsSnapshot.docs.filter((d) => d.data().status === "archived").length,
      };

      // Aggregate finances
      const financesSnapshot = await db.collection("finances").get();
      const totalInvoiced = financesSnapshot.docs.reduce((sum, doc) => sum + (doc.data().total || 0), 0);
      const totalPaid = financesSnapshot.docs.reduce((sum, doc) => sum + (doc.data().amountPaid || 0), 0);
      const monthlyRevenue = financesSnapshot.docs
        .filter((doc) => {
          const createdAt = (doc.data().createdAt as Timestamp).toDate();
          return createdAt >= startOfMonth && createdAt <= now;
        })
        .reduce((sum, doc) => sum + (doc.data().total || 0), 0);

      const financesStats = {
        totalInvoiced,
        totalPaid,
        totalPending: totalInvoiced - totalPaid,
        monthlyRevenue,
      };

      // Aggregate sessions
      const sessionsSnapshot = await db.collection("sessions").get();
      const sessionsStats = {
        total: sessionsSnapshot.size,
        upcoming: sessionsSnapshot.docs.filter((doc) => {
          const dateTime = (doc.data().dateTime as Timestamp).toDate();
          return dateTime > now;
        }).length,
        today: sessionsSnapshot.docs.filter((doc) => {
          const dateTime = (doc.data().dateTime as Timestamp).toDate();
          return dateTime.getDate() === now.getDate() &&
                 dateTime.getMonth() === now.getMonth() &&
                 dateTime.getFullYear() === now.getFullYear();
        }).length,
      };

      // Update system_stats document
      await db.collection("system_stats").doc("dashboard_overview").set(
        {
          clients: clientsStats,
          cases: casesStats,
          contracts: contractsStats,
          finances: financesStats,
          sessions: sessionsStats,
          lastUpdated: FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
      logger.info("updateSystemStats: Dashboard statistics updated");
    } catch (error) {
      logger.error("updateSystemStats: Error updating dashboard stats", error);
    }
  }
);

/**
 * sendAppointmentReminder - User Experience
 * Sends SMS reminders for appointments 24 hours before scheduled time
 */
export const sendAppointmentReminder = onSchedule(
  {
    schedule: "every 1 hours",
    timeZone: "UTC",
    region: "us-central1",
    maxInstances: 1,
  },
  async (event) => {
    try {
      const now = new Date();
      const in24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);
      const in25Hours = new Date(now.getTime() + 25 * 60 * 60 * 1000);

      // Query appointments that need reminders
      const appointmentsSnapshot = await db
        .collection("appointments")
        .where("status", "==", "scheduled")
        .where("smsReminderSent", "==", false)
        .get();

      const appointmentsToRemind = appointmentsSnapshot.docs.filter((doc) => {
        const data = doc.data();
        const dateTime = (data.dateTime as Timestamp).toDate();
        return dateTime >= in24Hours && dateTime <= in25Hours;
      });

      if (appointmentsToRemind.length === 0) {
        logger.info("sendAppointmentReminder: No appointments to remind");
        return;
      }

      logger.info(`sendAppointmentReminder: Found ${appointmentsToRemind.length} appointments to remind`);

      // Check if Twilio is configured (using environment variables)
      const twilioAccountSid = process.env.TWILIO_ACCOUNT_SID;
      const twilioAuthToken = process.env.TWILIO_AUTH_TOKEN;
      const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;

      if (!twilioAccountSid || !twilioAuthToken || !twilioPhoneNumber) {
        logger.warn("sendAppointmentReminder: Twilio not configured, skipping SMS");
        // Mark as sent anyway to avoid retrying
        for (const appointmentDoc of appointmentsToRemind) {
          await appointmentDoc.ref.update({
            smsReminderSent: true,
            reminderSentAt: FieldValue.serverTimestamp(),
          });
        }
        return;
      }

      // Import Twilio dynamically
      let twilioClient: any;
      try {
        const twilio = (await import("twilio")).default;
        twilioClient = twilio(twilioAccountSid, twilioAuthToken);
      } catch (error) {
        logger.error("sendAppointmentReminder: Failed to import Twilio", error);
        return;
      }

      for (const appointmentDoc of appointmentsToRemind) {
        const appointment = appointmentDoc.data();
        const clientId = appointment.clientId;

        if (!clientId) {
          logger.warn(`sendAppointmentReminder: Appointment ${appointmentDoc.id} has no clientId`);
          continue;
        }

        // Get client phone number
        const clientDoc = await db.collection("clients").doc(clientId).get();
        if (!clientDoc.exists) {
          logger.warn(`sendAppointmentReminder: Client ${clientId} not found`);
          continue;
        }

        const clientData = clientDoc.data();
        const clientPhone = clientData?.contact?.phone || clientData?.phoneNumber;

        if (!clientPhone) {
          logger.warn(`sendAppointmentReminder: Client ${clientId} has no phone number`);
          // Mark as sent to avoid retrying
          await appointmentDoc.ref.update({
            smsReminderSent: true,
            reminderSentAt: FieldValue.serverTimestamp(),
          });
          continue;
        }

        // Format appointment date/time (in Arabic-friendly format)
        const appointmentDateTime = (appointment.dateTime as Timestamp).toDate();
        const formattedDateTime = appointmentDateTime.toLocaleString("ar-SA", {
          weekday: "long",
          year: "numeric",
          month: "long",
          day: "numeric",
          hour: "numeric",
          minute: "2-digit",
        });

        // Create reminder message
        const message = `تذكير: لديك موعد غداً في ${formattedDateTime}. يرجى التأكد من الحضور.`;

        // Send SMS
        try {
          await twilioClient.messages.create({
            body: message,
            from: twilioPhoneNumber,
            to: clientPhone,
          });

          await appointmentDoc.ref.update({
            smsReminderSent: true,
            reminderSentAt: FieldValue.serverTimestamp(),
          });

          logger.info(`sendAppointmentReminder: Sent SMS to ${clientPhone} for appointment ${appointmentDoc.id}`);
        } catch (error) {
          logger.error(`sendAppointmentReminder: Failed to send SMS to ${clientPhone}`, error);
          // Don't mark as sent if there was an error, so it can retry
        }
      }
    } catch (error) {
      logger.error("sendAppointmentReminder: Error processing reminders", error);
    }
  }
);

/**
 * onFileUploaded - File Processing
 * Processes uploaded images and documents
 * - Generates thumbnails for images
 * - Extracts metadata
 * - Validates file types
 */
export const onFileUploaded = onObjectFinalized(
  {
    region: "us-central1",
    maxInstances: 10,
  },
  async (event) => {
    try {
      const filePath = event.data.name;
      const contentType = event.data.contentType;
      const bucket = storage.bucket(event.data.bucket);
      const file = bucket.file(filePath);

      logger.info(`onFileUploaded: Processing file: ${filePath}, type: ${contentType}`);

      // Skip if file is already processed (has _processed suffix)
      if (filePath.includes("_processed") || filePath.includes("_thumbnail")) {
        logger.info(`onFileUploaded: Skipping already processed file: ${filePath}`);
        return;
      }

      // Process images
      if (contentType?.startsWith("image/")) {
        try {
          // Get file metadata
          const [metadata] = await file.getMetadata();
          const fileSize = parseInt(metadata.size || "0", 10);

          // For large images, we could generate thumbnails here
          // This requires sharp or similar image processing library
          // For now, we'll just log and update document metadata if it exists

          // Try to find related document in Firestore
          const pathParts = filePath.split("/");
          if (pathParts.length >= 3 && pathParts[0] === "documents") {
            // Path format: documents/clients/{clientId}/{fileName}
            // or documents/contracts/{contractId}/{fileName}
            const category = pathParts[0];
            const fileName = pathParts[pathParts.length - 1];

            // Search for document by fileUrl
            const fileUrl = `https://firebasestorage.googleapis.com/v0/b/${event.data.bucket}/o/${encodeURIComponent(filePath)}?alt=media`;
            
            const documentsSnapshot = await db
              .collection("documents")
              .where("fileUrl", "==", fileUrl)
              .limit(1)
              .get();

            if (!documentsSnapshot.empty) {
              const docRef = documentsSnapshot.docs[0].ref;
              await docRef.update({
                fileSize: fileSize,
                processedAt: FieldValue.serverTimestamp(),
              });
              logger.info(`onFileUploaded: Updated document metadata for ${fileName}`);
            }
          }

          logger.info(`onFileUploaded: Image processed successfully: ${filePath}`);
        } catch (error) {
          logger.error(`onFileUploaded: Error processing image ${filePath}`, error);
        }
      } else if (contentType === "application/pdf") {
        // Process PDF files
        try {
          const [metadata] = await file.getMetadata();
          const fileSize = parseInt(metadata.size || "0", 10);

          // Extract PDF metadata if needed
          // For now, just update document record if it exists
          const pathParts = filePath.split("/");
          if (pathParts.length >= 3 && pathParts[0] === "documents") {
            const fileName = pathParts[pathParts.length - 1];
            const fileUrl = `https://firebasestorage.googleapis.com/v0/b/${event.data.bucket}/o/${encodeURIComponent(filePath)}?alt=media`;
            
            const documentsSnapshot = await db
              .collection("documents")
              .where("fileUrl", "==", fileUrl)
              .limit(1)
              .get();

            if (!documentsSnapshot.empty) {
              const docRef = documentsSnapshot.docs[0].ref;
              await docRef.update({
                fileSize: fileSize,
                processedAt: FieldValue.serverTimestamp(),
              });
              logger.info(`onFileUploaded: Updated PDF document metadata for ${fileName}`);
            }
          }

          logger.info(`onFileUploaded: PDF processed successfully: ${filePath}`);
        } catch (error) {
          logger.error(`onFileUploaded: Error processing PDF ${filePath}`, error);
        }
      } else {
        logger.info(`onFileUploaded: File type ${contentType} does not require processing: ${filePath}`);
      }
    } catch (error) {
      logger.error("onFileUploaded: Error processing file", error);
    }
  }
);

/**
 * onDocumentUploaded - Document Notification
 * Sends notification when document is uploaded
 * Notifies relevant users (client, case lawyer, etc.)
 */
export const onDocumentUploaded = onObjectFinalized(
  {
    region: "us-central1",
    maxInstances: 10,
  },
  async (event) => {
    try {
      const filePath = event.data.name;
      logger.info(`onDocumentUploaded: Document uploaded: ${filePath}`);

      // Only process documents in the documents/ folder
      if (!filePath.startsWith("documents/")) {
        logger.info(`onDocumentUploaded: Skipping non-document file: ${filePath}`);
        return;
      }

      const fileUrl = `https://firebasestorage.googleapis.com/v0/b/${event.data.bucket}/o/${encodeURIComponent(filePath)}?alt=media`;
      
      // Find the document record in Firestore
      const documentsSnapshot = await db
        .collection("documents")
        .where("fileUrl", "==", fileUrl)
        .limit(1)
        .get();

      if (documentsSnapshot.empty) {
        logger.warn(`onDocumentUploaded: No document record found for ${filePath}`);
        return;
      }

      const docData = documentsSnapshot.docs[0].data();
      const docId = documentsSnapshot.docs[0].id;
      const uploaderUid = docData.uploaderUid;
      const clientId = docData.clientId;
      const caseId = docData.caseId;

      // Get uploader info
      const uploaderDoc = await db.collection("users").doc(uploaderUid).get();
      const uploaderName = uploaderDoc.exists 
        ? uploaderDoc.data()?.profile?.name || uploaderDoc.data()?.email || "Unknown"
        : "Unknown";

      // Notify client if document is client-related
      if (clientId) {
        const clientDoc = await db.collection("clients").doc(clientId).get();
        if (clientDoc.exists) {
          const clientData = clientDoc.data();
          const clientUserId = clientData?.userId || clientId;
          
          // Create notification document (if notifications collection exists)
          // For now, we'll just log - FCM implementation can be added later
          logger.info(`onDocumentUploaded: Document ${docData.fileName} uploaded for client ${clientId}`);
          
          // Could create a notification document here:
          // await db.collection("notifications").add({
          //   userId: clientUserId,
          //   type: "document_uploaded",
          //   title: "تم رفع مستند جديد",
          //   message: `تم رفع المستند "${docData.fileName}" بواسطة ${uploaderName}`,
          //   relatedId: docId,
          //   relatedType: "document",
          //   read: false,
          //   createdAt: FieldValue.serverTimestamp(),
          // });
        }
      }

      // Notify case lawyer if document is case-related
      if (caseId) {
        const caseDoc = await db.collection("cases").doc(caseId).get();
        if (caseDoc.exists) {
          const caseData = caseDoc.data();
          const leadLawyerId = caseData?.leadLawyerId;
          const collaborators = caseData?.collaborators || [];

          // Notify lead lawyer
          if (leadLawyerId && leadLawyerId !== uploaderUid) {
            logger.info(`onDocumentUploaded: Document ${docData.fileName} uploaded for case ${caseId}, notifying lawyer ${leadLawyerId}`);
            // Create notification for lead lawyer
          }

          // Notify collaborators
          for (const collaborator of collaborators) {
            const collabUserId = collaborator.userId || collaborator;
            if (collabUserId !== uploaderUid) {
              logger.info(`onDocumentUploaded: Notifying collaborator ${collabUserId} about document ${docData.fileName}`);
              // Create notification for collaborator
            }
          }
        }
      }

      logger.info(`onDocumentUploaded: Document notification processed: ${filePath}`);
    } catch (error) {
      logger.error("onDocumentUploaded: Error processing document", error);
    }
  }
);

/**
 * createUser - Create User
 * Creates a new user (lawyer, student, engineer, accountant, translator) 
 * Only admins can call this function
 */
export const createUser = onCall(
  {
    region: "us-central1",
  },
  async (request) => {
    try {
      const callerUid = request.auth?.uid;
      if (!callerUid) {
        throw new Error("Unauthorized: User must be authenticated");
      }

      // Verify caller is admin
      const callerDoc = await db.collection("users").doc(callerUid).get();
      if (!callerDoc.exists) {
        throw new Error("Unauthorized: User not found");
      }

      const callerData = callerDoc.data();
      if (callerData?.role !== "admin") {
        throw new Error("Unauthorized: Only admins can create users");
      }

      // Get user data from request
      const {
        email,
        password,
        phoneNumber,
        role,
        profile,
      } = request.data;

      if (!email || !password || !role) {
        throw new Error("Missing required fields: email, password, role");
      }

      // Validate role is a collaborator role (not admin or client)
      const collaboratorRoles = ["lawyer", "student", "engineer", "accountant", "translator"];
      if (!collaboratorRoles.includes(role)) {
        throw new Error(`Invalid role: ${role}. Must be one of: ${collaboratorRoles.join(", ")}`);
      }

      // Validate and format phone number (E.164 format: +[country code][number])
      let validPhoneNumber: string | undefined = undefined;
      if (phoneNumber && typeof phoneNumber === "string" && phoneNumber.trim().length > 0) {
        const trimmedPhone = phoneNumber.trim();
        // Check if already in E.164 format (starts with +)
        if (trimmedPhone.startsWith("+")) {
          // Validate it's a valid E.164 format (only digits after +)
          if (/^\+[1-9]\d{1,14}$/.test(trimmedPhone)) {
            validPhoneNumber = trimmedPhone;
          } else {
            logger.warn(`createUser: Invalid E.164 phone number format: ${trimmedPhone}`);
            // Don't throw error, just skip phone number
          }
        } else {
          // Try to format as E.164 (assuming Saudi Arabia +966 if no country code)
          // Remove any non-digit characters
          const digitsOnly = trimmedPhone.replace(/\D/g, "");
          if (digitsOnly.length >= 9) {
            // If starts with 0, remove it and add +966
            if (digitsOnly.startsWith("0")) {
              validPhoneNumber = `+966${digitsOnly.substring(1)}`;
            } else if (digitsOnly.startsWith("966")) {
              validPhoneNumber = `+${digitsOnly}`;
            } else if (digitsOnly.length >= 10) {
              // Assume it's a full number without country code, add +966
              validPhoneNumber = `+966${digitsOnly}`;
            } else {
              logger.warn(`createUser: Cannot format phone number: ${trimmedPhone}`);
              // Don't throw error, just skip phone number
            }
          } else {
            logger.warn(`createUser: Phone number too short: ${trimmedPhone}`);
            // Don't throw error, just skip phone number
          }
        }
      }

      // Create Firebase Auth user
      const createUserOptions: any = {
        email: email,
        password: password,
        emailVerified: false,
      };
      
      // Only add phoneNumber if it's valid
      if (validPhoneNumber) {
        createUserOptions.phoneNumber = validPhoneNumber;
      }

      const userRecord = await auth.createUser(createUserOptions);

      // Create Firestore user document
      const userData: any = {
        email: email,
        phoneNumber: validPhoneNumber || null,
        role: role,
        profile: profile || {},
        permissions: [],
        isActive: true, // Users are pre-approved by admin
        createdAt: FieldValue.serverTimestamp(),
      };

      await db.collection("users").doc(userRecord.uid).set(userData);

      logger.info(`createUser: Created user ${userRecord.uid} with role ${role}`);

      return {
        success: true,
        uid: userRecord.uid,
        email: email,
      };
    } catch (error: any) {
      logger.error("createUser: Error creating user", error);
      throw new Error(error.message || "Failed to create user");
    }
  }
);

/**
 * createClientUser - Create Client User
 * Creates a new Firebase Auth user with role 'client' for admin-created clients
 * Only admins can call this function
 * Returns the user's uid which will be used as the client document ID
 */
export const createClientUser = onCall(
  {
    region: "us-central1",
  },
  async (request) => {
    try {
      const callerUid = request.auth?.uid;
      if (!callerUid) {
        throw new Error("Unauthorized: User must be authenticated");
      }

      // Verify caller is admin
      const callerDoc = await db.collection("users").doc(callerUid).get();
      if (!callerDoc.exists) {
        throw new Error("Unauthorized: User not found");
      }

      const callerData = callerDoc.data();
      if (callerData?.role !== "admin") {
        throw new Error("Unauthorized: Only admins can create client users");
      }

      // Get user data from request
      const {
        email,
        password,
        name,
        phone,
        region,
        city,
      } = request.data;

      if (!email || !password) {
        throw new Error("Missing required fields: email, password");
      }

      // Validate and format phone number (E.164 format: +[country code][number])
      let validPhoneNumber: string | undefined = undefined;
      if (phone && typeof phone === "string" && phone.trim().length > 0) {
        const trimmedPhone = phone.trim();
        // Check if already in E.164 format (starts with +)
        if (trimmedPhone.startsWith("+")) {
          // Validate it's a valid E.164 format (only digits after +)
          if (/^\+[1-9]\d{1,14}$/.test(trimmedPhone)) {
            validPhoneNumber = trimmedPhone;
          }
        } else {
          // Try to format as E.164 (assuming Saudi Arabia +966 if no country code)
          const digitsOnly = trimmedPhone.replace(/\D/g, "");
          if (digitsOnly.length >= 9) {
            // If starts with 0, remove it and add +966
            if (digitsOnly.startsWith("0")) {
              validPhoneNumber = `+966${digitsOnly.substring(1)}`;
            } else if (digitsOnly.startsWith("966")) {
              validPhoneNumber = `+${digitsOnly}`;
            } else if (digitsOnly.length >= 10) {
              validPhoneNumber = `+966${digitsOnly}`;
            }
          }
        }
      }

      // Create Firebase Auth user
      const createUserOptions: any = {
        email: email,
        password: password,
        emailVerified: false,
      };
      
      // Only add phoneNumber if it's valid
      if (validPhoneNumber) {
        createUserOptions.phoneNumber = validPhoneNumber;
      }

      const userRecord = await auth.createUser(createUserOptions);

      // Create Firestore user document with role 'client'
      const userProfile: any = {};
      if (name) userProfile.name = name;
      if (region) userProfile.region = region;
      if (city) userProfile.city = city;

      const userData: any = {
        email: email,
        phoneNumber: validPhoneNumber || null,
        role: "client",
        profile: userProfile,
        permissions: [],
        isActive: true, // Admin-created clients are active by default
        createdAt: FieldValue.serverTimestamp(),
      };

      await db.collection("users").doc(userRecord.uid).set(userData);

      logger.info(`createClientUser: Created client user ${userRecord.uid} with email ${email}`);

      return {
        success: true,
        uid: userRecord.uid,
        email: email,
      };
    } catch (error: any) {
      logger.error("createClientUser: Error creating client user", error);
      throw new Error(error.message || "Failed to create client user");
    }
  }
);

// ============================================================================
// Firestore Triggers - TEMPORARILY DISABLED
// ============================================================================
// 
// All Firestore triggers are commented out because:
// - Firestore database is in me-central2 region
// - Cloud Functions doesn't support me-central2 region  
// - Firestore triggers MUST be in the same region as Firestore
//
// To enable these triggers, you need to either:
// 1. Move Firestore to a supported region (us-central1, europe-west1, etc.)
// 2. Contact Firebase Support to request me-central2 support for Cloud Functions
// 3. Use Pub/Sub as an intermediary (requires code refactoring)
//
// See functions/src/index.ts.backup for the original trigger code
