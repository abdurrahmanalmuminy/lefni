# Firebase Permissions Audit Plan

## Overview
Comprehensive audit plan to verify all Firebase security rules, service layer permissions, and UI access controls are working correctly based on user roles.

## User Roles in System
- **admin**: Full system access
- **lawyer**: Can access assigned cases, consultations, sessions
- **student**: Limited access (training/case sourcing)
- **engineer**: Engineering services access
- **accountant**: Financial access
- **translator**: Translation services access
- **client**: Can only access own resources (cases, consultations, documents)

## Audit Areas

### 1. Firestore Security Rules Audit (`firestore.rules`)

#### 1.1 Helper Functions Verification
- [ ] Verify `isAuthenticated()` correctly checks `request.auth != null`
- [ ] Verify `getUserData()` handles null cases properly
- [ ] Verify `hasUserData()` correctly checks both auth and user data existence
- [ ] Verify `isAdmin()` correctly identifies admin role
- [ ] Verify `getUserRole()` returns correct role or null
- [ ] Verify `hasPermission(permission)` correctly checks permissions array
- [ ] Verify `hasResourcePermission(collection, resourceId)` format matches service usage
- [ ] Verify `hasCreatePermission(collection)` format matches service usage
- [ ] Verify `isClient()` correctly identifies client role
- [ ] Verify `isClientOwner(clientId)` handles both direct uid match and userId field match
- [ ] Verify `canClientAccessResource(resource)` correctly checks clientId field

#### 1.2 Collection-Specific Rules

**Users Collection (`/users/{userId}`)**
- [ ] Read: Users can read own profile OR admin can read any
- [ ] Create: Users can create own document with required fields validation
- [ ] Update: Users can update own profile/lastLogin only, admin can update anything
- [ ] Delete: Admin only

**Clients Collection (`/clients/{clientId}`)**
- [ ] Read: Admin, resource permission, or client owner
- [ ] Create: Admin with validation, create permission, or client creating own
- [ ] Update: Admin, resource permission, or client updating own
- [ ] Delete: Admin only

**Cases Collection (`/cases/{caseId}`)**
- [ ] Read: Admin, client owner, lead lawyer, collaborators, or resource permission
- [ ] Create: Admin with validation OR create permission
- [ ] Update: Admin, lead lawyer, collaborators, or resource permission
- [ ] Delete: Admin only
- [ ] Verify clients cannot create cases directly

**Contracts Collection (`/contracts/{contractId}`)**
- [ ] Read: Admin, client owner, or resource permission
- [ ] Create: Admin with validation OR create permission
- [ ] Update: Admin, resource permission, or client updating signatureStatus only
- [ ] Delete: Admin only
- [ ] Verify audit_log subcollection rules

**Sessions Collection (`/sessions/{sessionId}`)**
- [ ] Read: Admin, lawyer owner, client owner, or resource permission
- [ ] Create: Admin with validation OR create permission
- [ ] Update: Admin, create permission, or resource permission
- [ ] Delete: Admin only

**Tasks Collection (`/tasks/{taskId}`)**
- [ ] Read: Admin, resource permission, assignedTo, createdBy, or client with relatedType='client'
- [ ] Create: Admin with validation OR create permission
- [ ] Update: Admin, resource permission, or assignedTo
- [ ] Delete: Admin only

**Finances Collection (`/finances/{financeId}`)**
- [ ] Read: Admin, client owner, resource permission, or view_finances permission
- [ ] Create: Admin with validation OR create permission
- [ ] Update: Admin, create permission, or resource permission
- [ ] Delete: Admin only

**Documents Collection (`/documents/{documentId}`)**
- [ ] Read: Admin, resource permission, uploaderUid, or client owner
- [ ] Create: Admin with validation, create permission, or uploaderUid match
- [ ] Update: Admin, resource permission, or uploaderUid
- [ ] Delete: Admin, resource permission, or uploaderUid

**Expenses Collection (`/expenses/{expenseId}`)**
- [ ] Read: Admin, resource permission, or createdBy
- [ ] Create: Admin with validation, create permission, or createdBy match
- [ ] Update: Admin, resource permission, or createdBy
- [ ] Delete: Admin, resource permission, or createdBy

**Appointments Collection (`/appointments/{appointmentId}`)**
- [ ] Read: Admin, resource permission, client owner, or createdBy
- [ ] Create: Admin with validation, create permission, or createdBy match
- [ ] Update: Admin, resource permission, or createdBy
- [ ] Delete: Admin, resource permission, or createdBy

**Collection Records Collection (`/collection_records/{recordId}`)**
- [ ] Read: Admin, resource permission, or recordedBy
- [ ] Create: Admin, create permission with validation, or recordedBy match
- [ ] Update: Admin, resource permission, or recordedBy
- [ ] Delete: Admin or resource permission

**Consultations Collection (`/consultations/{consultationId}`)**
- [ ] Read: Admin, client owner, or assigned lawyer
- [ ] Create: Admin with validation OR client creating own with status='pending'
- [ ] Update: Admin, client (limited fields), or assigned lawyer (limited fields)
- [ ] Delete: Admin only
- [ ] Verify client can only update description, attachments, updatedAt
- [ ] Verify lawyer can only update response, responseAt, status, updatedAt

**System Stats Collection (`/system_stats/{document=**}`)**
- [ ] Read: Admin or view_system_stats permission
- [ ] Write: false (Cloud Functions only)

### 2. Storage Security Rules Audit (`storage.rules`)

#### 2.1 Helper Functions
- [ ] Verify `isAuthenticated()` works correctly
- [ ] Verify `getUserData()` correctly fetches from Firestore
- [ ] Verify `isAdmin()` correctly identifies admin
- [ ] Verify `isClient()` correctly identifies client

#### 2.2 Path-Specific Rules

**General Documents (`/documents/{documentId}`)**
- [ ] Read: Any authenticated user
- [ ] Write: Any authenticated user with 10MB limit

**Client Documents (`/documents/clients/{clientId}/{fileName}`)**
- [ ] Read: Admin or client owner (clientId == uid)
- [ ] Write: Admin or client owner with 10MB limit

**Contract Documents (`/documents/contracts/{contractId}/{fileName}`)**
- [ ] Read: Any authenticated user
- [ ] Write: Admin or create_contract permission with 10MB limit

**Report Documents (`/documents/reports/{fileName}`)**
- [ ] Read: Any authenticated user
- [ ] Write: Admin only with 10MB limit

**Contract Files (`/contracts/{contractId}/{fileName}`)**
- [ ] Read: Any authenticated user
- [ ] Write: Admin or create_contract permission with 10MB limit

**Agency Images (`/agencies/{clientId}/{fileName}`)**
- [ ] Read: Admin or client owner
- [ ] Write: Admin or client owner with 5MB limit

**Receipt Images (`/receipts/{expenseId}/{fileName}`)**
- [ ] Read: Any authenticated user
- [ ] Write: Any authenticated user with 5MB limit

**Default Deny (`/{allPaths=**}`)**
- [ ] Verify all other paths are denied

### 3. Service Layer Permission Checks

#### 3.1 Service Files to Audit
For each service in `lib/services/firestore/`, verify:
- [ ] No service bypasses security rules by using admin SDK
- [ ] Services properly handle `permission-denied` exceptions
- [ ] Services don't perform client-side permission checks that could be bypassed
- [ ] Services use correct collection names matching security rules

**Services to Check:**
- [ ] `user_service.dart` - User CRUD operations
- [ ] `client_service.dart` - Client CRUD operations
- [ ] `case_service.dart` - Case CRUD operations
- [ ] `contract_service.dart` - Contract CRUD operations
- [ ] `session_service.dart` - Session CRUD operations
- [ ] `task_service.dart` - Task CRUD operations
- [ ] `finance_service.dart` - Finance CRUD operations
- [ ] `document_service.dart` - Document CRUD operations
- [ ] `expense_service.dart` - Expense CRUD operations
- [ ] `appointment_service.dart` - Appointment CRUD operations
- [ ] `collection_record_service.dart` - Collection record CRUD operations
- [ ] `consultation_service.dart` - Consultation CRUD operations
- [ ] `audit_log_service.dart` - Audit log operations
- [ ] `system_stats_service.dart` - System stats read operations

#### 3.2 Service Pattern Verification
- [ ] All services use `FirebaseFirestore.instance` (not admin SDK)
- [ ] All services catch `FirebaseException` with `permission-denied` code
- [ ] All services throw appropriate exceptions for permission errors
- [ ] No services perform operations that require admin privileges

### 4. UI Layer Permission Checks

#### 4.1 Dashboard Access Control (`lib/ui/dashboard.dart`)
- [ ] Clients blocked from `/invoices/*` routes
- [ ] Clients blocked from `/reports/*` routes
- [ ] Clients blocked from `/users/*` routes
- [ ] `_canAccessInvoices()` correctly checks role
- [ ] `_canAccessReports()` correctly checks role
- [ ] `_canAccessUsers()` correctly checks role (admin only)
- [ ] Inactive users redirected to waiting activation page

#### 4.2 Page-Level Access Control
For each page, verify:
- [ ] List pages filter data based on user role
- [ ] Detail pages check ownership/permissions before showing
- [ ] Edit pages check permissions before allowing edits
- [ ] Create forms check create permissions

**Pages to Check:**
- [ ] `cases_list_page.dart` - Filter cases by role
- [ ] `case_detail_page.dart` - Check case access
- [ ] `clients_list_page.dart` - Filter clients by role
- [ ] `client_detail_page.dart` - Check client access
- [ ] `consultations_list_page.dart` - Filter consultations by role
- [ ] `consultation_detail_page.dart` - Check consultation access
- [ ] `documents_list_page.dart` - Filter documents by role
- [ ] `finances_list_page.dart` - Filter finances by role
- [ ] All other list/detail/edit pages

#### 4.3 Form-Level Access Control
- [ ] Create forms check `hasCreatePermission()` or role
- [ ] Edit forms check resource ownership/permissions
- [ ] Delete buttons only shown for users with delete permissions
- [ ] Field-level restrictions (e.g., clients can only edit certain fields)

### 5. Role-Based Access Matrix

#### 5.1 Admin Role
- [ ] Full read access to all collections
- [ ] Full write access to all collections
- [ ] Can delete any resource
- [ ] Can update any resource
- [ ] Can create resources in any collection
- [ ] Can access all UI routes

#### 5.2 Lawyer Role
- [ ] Can read assigned cases (leadLawyerId or collaborators)
- [ ] Can read assigned consultations (assignedLawyerId)
- [ ] Can read sessions where lawyerId matches
- [ ] Can update assigned consultations (limited fields)
- [ ] Can update assigned cases
- [ ] Cannot delete cases or consultations
- [ ] Cannot access invoices/reports/users tabs (unless has permissions)

#### 5.3 Client Role
- [ ] Can read own clients document (uid == clientId or userId match)
- [ ] Can read own cases (clientId == uid)
- [ ] Can read own consultations (clientId == uid)
- [ ] Can read own contracts (clientId == uid)
- [ ] Can read own documents (clientId == uid or uploaderUid)
- [ ] Can create own consultations (status='pending' only)
- [ ] Can update own consultations (description, attachments, updatedAt only)
- [ ] Can update own contracts (signatureStatus only)
- [ ] Cannot delete any resources
- [ ] Cannot access invoices/reports/users tabs
- [ ] Cannot create cases, contracts, sessions directly

#### 5.4 Other Roles (student, engineer, accountant, translator)
- [ ] Verify role-specific permissions are correctly enforced
- [ ] Verify these roles cannot access admin-only features
- [ ] Verify these roles follow permission-based access model

### 6. Permission System Verification

#### 6.1 Permission Format
- [ ] Verify permission format: `"collection:resourceId"` for resource permissions
- [ ] Verify permission format: `"create_collection"` for create permissions
- [ ] Verify permission format: `"view_system_stats"` for system permissions
- [ ] Verify permissions array is properly stored in user document

#### 6.2 Permission Assignment
- [ ] Verify permissions are assigned by admin only
- [ ] Verify permissions cannot be self-assigned
- [ ] Verify permissions are validated before assignment

### 7. Edge Cases & Vulnerabilities

#### 7.1 Authentication Edge Cases
- [ ] Unauthenticated users cannot access any resources
- [ ] Users with deleted user documents cannot access resources
- [ ] Users with isActive=false are blocked (handled in dashboard)
- [ ] Token expiration is handled correctly

#### 7.2 Data Validation
- [ ] Required fields are validated in security rules
- [ ] Field types are validated (string, number, timestamp, etc.)
- [ ] Field size limits are enforced
- [ ] Enum values are validated where applicable

#### 7.3 Client Ownership Edge Cases
- [ ] Client with uid == clientId can access resources
- [ ] Client with userId field match can access resources
- [ ] Client cannot access other clients' resources
- [ ] Client cannot modify clientId field to gain access

#### 7.4 Update Restrictions
- [ ] Clients can only update specific fields in consultations
- [ ] Lawyers can only update specific fields in consultations
- [ ] Field diff validation works correctly
- [ ] Users cannot bypass field restrictions

#### 7.5 Storage Edge Cases
- [ ] File size limits are enforced (10MB documents, 5MB images)
- [ ] Clients cannot access other clients' files
- [ ] File paths cannot be manipulated to access unauthorized files
- [ ] Default deny rule catches all unmatched paths

### 8. Testing Strategy

#### 8.1 Unit Tests for Security Rules
- [ ] Test each collection's read rules with different roles
- [ ] Test each collection's create rules with different roles
- [ ] Test each collection's update rules with different roles
- [ ] Test each collection's delete rules with different roles
- [ ] Test helper functions with edge cases

#### 8.2 Integration Tests
- [ ] Test service layer operations with different user roles
- [ ] Test permission-denied exceptions are thrown correctly
- [ ] Test UI access controls with different roles
- [ ] Test end-to-end flows for each role

#### 8.3 Manual Testing Checklist
- [ ] Test as admin: Verify full access
- [ ] Test as lawyer: Verify assigned resources only
- [ ] Test as client: Verify own resources only
- [ ] Test as inactive user: Verify redirect to waiting page
- [ ] Test unauthorized access attempts: Verify proper blocking
- [ ] Test permission-based access: Verify permissions work correctly

### 9. Common Issues to Check

#### 9.1 Security Rule Issues
- [ ] Missing null checks in helper functions
- [ ] Incorrect field name references (e.g., `clientId` vs `userId`)
- [ ] Missing validation for required fields
- [ ] Incorrect permission format checks
- [ ] Missing default deny rules

#### 9.2 Service Layer Issues
- [ ] Services using admin SDK instead of client SDK
- [ ] Services not handling permission errors
- [ ] Services performing operations without checking permissions first
- [ ] Services using wrong collection names

#### 9.3 UI Layer Issues
- [ ] UI showing data user shouldn't see
- [ ] UI allowing actions user shouldn't perform
- [ ] UI not checking permissions before operations
- [ ] UI not filtering data based on role

### 10. Documentation Updates

After audit, document:
- [ ] Permission model and how it works
- [ ] Role-based access matrix
- [ ] How to add new permissions
- [ ] How to test security rules
- [ ] Common security patterns used

## Audit Execution Order

1. **Phase 1: Security Rules Review**
   - Review all Firestore rules
   - Review all Storage rules
   - Identify any obvious issues

2. **Phase 2: Service Layer Review**
   - Review each service file
   - Verify no admin SDK usage
   - Verify proper error handling

3. **Phase 3: UI Layer Review**
   - Review dashboard access controls
   - Review page-level access controls
   - Review form-level access controls

4. **Phase 4: Testing**
   - Create test cases for each role
   - Test edge cases
   - Verify all access controls work

5. **Phase 5: Fixes & Documentation**
   - Fix any identified issues
   - Update documentation
   - Create security testing guide

## Priority Issues to Address First

1. **Critical**: Any rules that allow unauthorized access
2. **High**: Missing permission checks in UI
3. **High**: Services using admin SDK
4. **Medium**: Missing field validations
5. **Medium**: Edge cases not handled
6. **Low**: Documentation updates
