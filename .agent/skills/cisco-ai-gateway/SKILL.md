# Cisco AI Gateway Skill

## Purpose
This skill manages the configuration, verification, and maintenance of the connection to the Cisco AI Gateway.

## Configuration Requirements
The following environment variables MUST be present in the project `.env` file:

```bash
CISCO_AI_TIER=free                      # options: free, payg
CISCO_AI_MODEL=gpt-4.1                  # options: gpt-4o, gpt-4o-mini, gpt-4.1
CISCO_AI_CLIENT_ID=                     # OAuth2 Client ID
CISCO_AI_CLIENT_SECRET=                 # OAuth2 Client Secret
CISCO_AI_API_KEY=                       # App-Key / API-Key
CISCO_AI_TOKEN_URL=https://id.cisco.com/oauth2/default/v1/token
CISCO_AI_ENDPOINT=https://chat-ai.cisco.com
CISCO_AI_API_VERSION=2023-12-01-preview
```

## Credential Recovery
If credentials are lost:
1. Access the **Cisco AI Gateway Portal** (Internal).
2. Look for the application registered as **DAP** or contact the AI Gateway SME.
3. OAuth credentials (ID/Secret) are managed via Cisco SSO/Ping.
4. The `API_KEY` (App-Key) is specific to the Chat-AI deployment.

## Connectivity Verification
To verify the connection from any environment:

1. Locate the test script: `backend/src/scripts/test-cisco-connectivity.ts` (if available) or create a temporary one.
2. Run the diagnostic:
   ```bash
   cd backend
   npx ts-node src/scripts/test-cisco-connectivity.ts
   ```
3. Successful output should show:
   - `[CiscoAI] Access token obtained successfully`
   - `Response status: 200`
   - AI Response: "Connected"

## Troubleshooting Common Errors
- **401 Unauthorized**: Mismatch in `CLIENT_ID` or `CLIENT_SECRET`.
- **403 Forbidden**: `API_KEY` (App-Key) is invalid or the app registration is not approved for the requested model.
- **404 Not Found**: The `CISCO_AI_MODEL` is not available in the selected `CISCO_AI_TIER`.
- **Latency > 5s**: Check if you are on VPN or if the Cisco AI Gateway is experiencing high load.
