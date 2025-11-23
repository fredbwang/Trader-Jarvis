# Testing Guide

## Isolated Test Environment

The project includes an isolated testing environment that runs on separate ports from your development servers, allowing you to test without interrupting your work.

### Port Configuration

| Environment | Backend Port | Frontend Port |
|------------|--------------|---------------|
| Development | 8000 | 3000 |
| Testing | 8001 | 3001 |

### Test Scripts

Test scripts are located in `test/server-test/`.

#### Automated Test Suite
```powershell
.\test\server-test\test-server.ps1
```
Runs complete automated test suite that:
- Cleans up any existing test servers
- Starts test servers on ports 8001/3001
- Verifies ports are listening
- Tests HTTP endpoints (/health, root, frontend)
- Verifies dev servers are unaffected
- Stops test servers and verifies cleanup
- Reports pass/fail results

#### Start Test Servers (Manual)
```powershell
.\test\server-test\start-test.ps1
```
Starts backend and frontend servers on test ports (8001, 3001).

#### Stop Test Servers (Manual)
```powershell
.\test\server-test\stop-test.ps1
```
Stops only the test servers, leaving dev servers (8000, 3000) running.

### Environment Files

Test servers use separate configuration files:
- `backend/.env.test` - Test backend configuration (port 8001)
- `frontend/.env.test` - Test frontend configuration (port 3001)

These configurations use a separate test database and Redis instance to avoid conflicts with development data.

### How It Works

1. **Separate Ports**: Test servers run on 8001/3001, dev servers on 8000/3000
2. **Separate Config**: `.env.test` files keep test configuration isolated
3. **Smart Stop**: stop-test.ps1 only kills processes on test ports

### Typical Workflow

```powershell
# Start your dev servers
.\start.ps1

# Later, start test environment without stopping dev servers
.\test\server-test\start-test.ps1

# Manually test at:
#   Backend:  http://localhost:8001/health
#   Frontend: http://localhost:3001

# Clean up test environment when done
.\test\server-test\stop-test.ps1

# Your dev servers on 8000/3000 are still running!
```
