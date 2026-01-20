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
import {onSchedule} from "firebase-functions/v2/scheduler";
import {onObjectFinalized} from "firebase-functions/v2/storage";
import {onCall} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

// Initialize Firebase Admin
initializeApp();
const db = getFirestore();
const auth = getAuth();

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
      logger.info("sendAppointmentReminder: Placeholder - Twilio integration needed");
      // TODO: Implement Twilio SMS sending when credentials are configured
    } catch (error) {
      logger.error("sendAppointmentReminder: Error processing reminders", error);
    }
  }
);

/**
 * onFileUploaded - File Processing
 * Processes uploaded images and documents
 */
export const onFileUploaded = onObjectFinalized(
  {
    region: "us-central1",
    maxInstances: 10,
  },
  async (event) => {
    try {
      const filePath = event.data.name;
      logger.info(`onFileUploaded: File uploaded: ${filePath}`);
      // TODO: Implement file processing logic
    } catch (error) {
      logger.error("onFileUploaded: Error processing file", error);
    }
  }
);

/**
 * onDocumentUploaded - Document Notification
 * Sends notification when document is uploaded
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
      // TODO: Implement notification logic
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
