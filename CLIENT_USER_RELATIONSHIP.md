# Client-User Relationship Documentation

## Overview

In the Lefni system, clients are users with the role `'client'`. To ensure proper access control through Firestore security rules, there is a critical relationship that must be maintained:

**For client users: `clientId == userId == user.uid`**

## Implementation

### Admin-Created Clients

When an admin creates a client through the UI:

1. **Method Used:** `ClientService.createClientWithUser()`
2. **Process:**
   - Creates Firebase Auth user via Cloud Function `createClientUser`
   - Uses the returned `uid` as the client document ID
   - Sets `userId` field on client document to the same `uid`
   - Result: `clientId == userId == user.uid`

**File:** `lib/services/firestore/client_service.dart:createClientWithUser()`

### Phone Signup Clients

When a user signs up via phone number:

1. **Method Used:** `ClientService.createClientForUser()`
2. **Process:**
   - User already exists in Firebase Auth (from phone verification)
   - Creates client document using `userId` as document ID
   - Sets `userId` field on client document
   - Result: `clientId == userId == user.uid`

**File:** `lib/services/firestore/client_service.dart:createClientForUser()`

### Email Signup Clients

When a user signs up via email:

1. **Method Used:** `AuthService.signUp()` + automatic client creation
2. **Process:**
   - User created in Firebase Auth
   - User document created in Firestore
   - Client document should be created using `createClientForUser()` with the user's `uid`
   - Result: `clientId == userId == user.uid`

## Access Control

Firestore security rules use this relationship to allow clients to access their resources:

```javascript
function canClientAccessResource(resource) {
  return isClient() && 
         'clientId' in resource.data && (
           resource.data.clientId == request.auth.uid ||
           isClientOwner(resource.data.clientId)
         );
}
```

Resources (cases, contracts, finances, appointments, etc.) reference `clientId`, which matches the user's `uid` for client users.

## Important Notes

1. **Never use `createClient()` directly** - This method is deprecated and creates clients without user accounts, breaking the access control model.

2. **Always ensure `clientId == userId`** - This is critical for Firestore rules to work correctly.

3. **Legacy Clients** - If you have existing clients created with `createClient()`, they will need to be migrated to have matching user accounts.

4. **Client Document Structure:**
   - Document ID: `user.uid` (for client users)
   - `userId` field: `user.uid` (for reference)
   - `contact.email`: Required for admin-created clients (used to create user account)

## Migration

If you have existing clients without matching user accounts:

1. Create Firebase Auth user for each client
2. Update client document ID to match user uid
3. Set `userId` field on client document
4. Update all resources referencing the old clientId
