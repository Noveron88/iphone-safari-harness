# iPhone Safari visual QA for Claude Code

The private Model-Agency project is at `C:\Users\adria\projects\Model-Agency`. Its GitHub Actions quota is exhausted. This separate public harness runs iPhone 14 Simulator Safari; never copy Model-Agency code, environment files, credentials, or client data into this repo.

Before editing Model-Agency, read its `AGENTS.md`, newest handoff issue, onboarding, and known mistakes. Follow that project's workflow and closing requirements.

For a meaningful mobile UI change:

1. Use `powershell -ExecutionPolicy Bypass -File .\scripts\run-modelagency.ps1 -Page '/desired/path'` from this folder for the current local code. It refuses the known production database, starts a short lived test server and Cloudflare tunnel, dispatches the Safari workflow, downloads the artifact, then closes the tunnel.
2. For the already deployed test site, use `powershell -ExecutionPolicy Bypass -File .\scripts\run-check.ps1 -Url 'https://model-agency-test.onrender.com/desired/path'`.
3. Read only the small `report.json`, then inspect the `screenshot.png` image. Do not send image base64 or full workflow logs into the context.
4. Fix concrete visible layout errors in the project, then rerun once. State which URL and build were actually checked. A screenshot of a login page proves only the login page.

Never claim iPhone Safari verification unless the workflow succeeds and you inspect its screenshot. The simulator is not physical iPhone hardware. If the iPhone 14 device type is unavailable, report that limitation.
