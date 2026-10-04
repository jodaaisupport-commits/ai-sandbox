# AI Sandbox

## Deploy to Vercel

Create a Vercel project for this repository and set its **Root Directory** to
`ai-sandbox-backend`. Vercel will detect the Next.js framework; the project
build command is `npm run build`.

Add these environment variables in the Vercel project settings for each
environment you deploy:

- `DATABASE_URL`: connection string for the PostgreSQL database.
- `JWT_SECRET`: a strong, unique secret used to sign authentication tokens.
- `GONKA_API_KEY`: API key for Gonka chat requests.

Then deploy the project from Vercel or push a commit to the connected Git
branch to trigger a deployment.
