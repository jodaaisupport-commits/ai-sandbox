exit
ai-sandbox
cd ai-sandbox
cd ~/ai-sandbox
cd ~/ai-sandbox-backend
cd ~
mkdir -p ai-sandbox-backend
cd ai-sandbox-backend
# package.json erstellen
cat > package.json << 'EOF'
{
  "name": "ai-sandbox-backend",
  "version": "4.2.0",
  "scripts": { "dev": "next dev", "build": "next build", "start": "next start" },
  "dependencies": {
    "next": "^14.2.0",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "prisma": "^5.13.0",
    "@prisma/client": "^5.13.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "@neon/config": "^1.0.0"
  }
}
EOF

# neon.ts
cat > neon.ts << 'EOF'
import { defineConfig } from "@neon/config/v1";
export default defineConfig({
  auth: true,
  preview: {
    functions: {
      api: { name: "api", source: "./hello.ts" },
    },
  },
});
EOF

# hello.ts
cat > hello.ts << 'EOF'
export default async function hello(): Promise<Response> {
  return new Response("Hello from Neon Functions");
}
EOF

# .gitignore
cat > .gitignore << 'EOF'
node_modules
.next/
.env
.neon/
dist
EOF

ls -la
npm i -g neon@latest
neon login
neon link --project-id still-field-03608854 --branch production -y
neon config init
neon deploy
pkg install git
git init
git config --global user.name "jodaaisupport-commits"
git config --global user.email "jodaaisupport@gmail.com"
git add .
git commit -m "feat: v4.2 Neon Functions + Backend"
git remote add origin https://github.com/jodaaisupport-commits/ai-sandbox.git
git branch -M main
git push -u origin main
git auth
git auth status
git status
gh auth login
pkg install gh
gh auth login
git push -u origin main
git pull origin main --rebase
git push origin main
git status
cd
cd ai-sandbox-backend
npm install
npm install-scripts ls
npm install-scripts approve <pkg>
npm install-scripts approve npm
pkg install npm
npm install-scripts approve <npm>
pwd
ls
cd ~
rm -rf ai-sandbox-backend
mkdir -p ai-sandbox-backend/{prisma,lib,pages/api/{auth,gonka,admin,prompts}}
cd ai-sandbox-backend
cat > package.json << 'EOF'
{
  "name": "ai-sandbox-backend",
  "version": "4.2.0",
  "scripts": { "dev": "next dev", "build": "next build", "start": "next start" },
  "dependencies": {
    "next": "^14.2.0",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "prisma": "^5.13.0",
    "@prisma/client": "^5.13.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "@neon/config": "^1.0.0"
  }
}
EOF

cat > neon.ts << 'EOF'
import { defineConfig } from "@neon/config/v1";
export default defineConfig({
  auth: true,
  preview: {
    functions: { api: { name: "api", source: "./hello.ts" } },
  },
});
EOF

cat > hello.ts << 'EOF'
export default async function hello(): Promise<Response> {
  return new Response("Hello from Neon Functions");
}
EOF

cat >.env.example << 'EOF'
DATABASE_URL="postgresql://user:password@ep-xxx.neon.tech/neondb?sslmode=require"
GONKA_API_KEY="gkr_your_key"
JWT_SECRET="supersecret_32_chars_1234567890"
ADMIN_EMAIL="admin@ai-sandbox.pro"
EOF

cat >.gitignore << 'EOF'
node_modules
.next/
.env
.neon/
dist
out
*.log
EOF

cat > prisma/schema.prisma << 'EOF'
generator client { provider = "prisma-client-js" }
datasource db { provider = "postgresql" url = env("DATABASE_URL") }
model User {
  id String @id @default(cuid())
  name String
  email String @unique
  password String
  role String @default("user")
  createdAt DateTime @default(now())
  prompts Prompt[]
  logs Log[]
}
model Prompt {
  id String @id @default(cuid())
  userId String
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
  title String
  prompt String
  createdAt DateTime @default(now())
}
model Log {
  id String @id @default(cuid())
  userId String?
  user User? @relation(fields: [userId], references: [id])
  action String
  model String?
  tokens Int?
  createdAt DateTime @default(now())
}
model SystemSetting {
  id String @id @default("global")
  defaultModel String @default("Qwen3-235B-A22B-Instruct-2507-FP8")
  pricingPer1M Float @default(0.0004)
  updatedAt DateTime @updatedAt
}
EOF

cat > lib/prisma.js << 'EOF'
import { PrismaClient } from '@prisma/client'
const globalForPrisma = globalThis
export const prisma = globalForPrisma.prisma || new PrismaClient()
if (process.env.NODE_ENV!== 'production') globalForPrisma.prisma = prisma
EOF

cat > lib/auth.js << 'EOF'
import jwt from 'jsonwebtoken'
import bcrypt from 'bcryptjs'
const SECRET = process.env.JWT_SECRET || 'dev-secret'
export const signToken = (u) => jwt.sign({id:u.id, email:u.email, role:u.role}, SECRET, {expiresIn:'7d'})
export const verifyToken = (t) => { try{return jwt.verify(t, SECRET)}catch{return null} }
export const hashPassword = (pw) => bcrypt.hash(pw, 10)
export const comparePassword = (pw, hash) => bcrypt.compare(pw, hash)
export const getTokenFromReq = (req) => { const a=req.headers.authorization||''; return a.startsWith('Bearer ')?a.slice(7):null }
EOF

cat > pages/api/auth/register.js << 'EOF'
import { prisma } from '../../../lib/prisma'
import { hashPassword, signToken } from '../../../lib/auth'
export default async function handler(req,res){
 if(req.method!=='POST') return res.status(405).end()
 const {name,email,password}=req.body
 if(!email||!password) return res.status(400).json({error:'Email+Password required'})
 const exists=await prisma.user.findUnique({where:{email}})
 if(exists) return res.status(400).json({error:'User exists'})
 const hashed=await hashPassword(password)
 const user=await prisma.user.create({data:{name:name||email.split('@')[0], email, password:hashed, role: email===process.env.ADMIN_EMAIL?'admin':'user'}})
 const token=signToken(user)
 res.json({token, user:{id:user.id, email:user.email, role:user.role, name:user.name}})
}
EOF

cat > pages/api/auth/login.js << 'EOF'
import { prisma } from '../../../lib/prisma'
import { comparePassword, signToken } from '../../../lib/auth'
export default async function handler(req,res){
 if(req.method!=='POST') return res.status(405).end()
 const {email,password}=req.body
 const user=await prisma.user.findUnique({where:{email}})
 if(!user) return res.status(401).json({error:'User not found'})
 const ok=await comparePassword(password,user.password)
 if(!ok) return res.status(401).json({error:'Wrong password'})
 const token=signToken(user)
 res.json({token, user:{id:user.id, email:user.email, role:user.role, name:user.name}})
}
EOF

cat > pages/api/auth/me.js << 'EOF'
import { verifyToken, getTokenFromReq } from '../../../lib/auth'
import { prisma } from '../../../lib/prisma'
export default async function handler(req,res){
 const token=getTokenFromReq(req)
 const data=token?verifyToken(token):null
 if(!data) return res.status(401).json({error:'Unauthorized'})
 const user=await prisma.user.findUnique({where:{id:data.id}})
 res.json({user:{id:user.id, email:user.email, role:user.role, name:user.name}})
}
EOF

cat > pages/api/gonka/chat.js << 'EOF'
import { prisma } from '../../../lib/prisma'
import { verifyToken, getTokenFromReq } from '../../../lib/auth'
export default async function handler(req,res){
 if(req.method!=='POST') return res.status(405).end()
 const token=getTokenFromReq(req)
 const user=token?verifyToken(token):null
 if(!user) return res.status(401).json({error:'Login required'})
 const {model,messages,temperature=0.7}=req.body
 const r=await fetch('https://api.gonkarouter.io/v1/chat/completions',{
  method:'POST',
  headers:{'Authorization':`Bearer ${process.env.GONKA_API_KEY}`,'Content-Type':'application/json'},
  body: JSON.stringify({model:model||'Qwen3-235B-A22B-Instruct-2507-FP8', messages, temperature})
 })
 const data=await r.json()
 if(!r.ok) return res.status(r.status).json(data)
 await prisma.log.create({data:{userId:user.id, action:'gonka_call', model, tokens:data.usage?.total_tokens||0}})
 res.json(data)
}
EOF

cat > pages/api/admin/users.js << 'EOF'
import { prisma } from '../../../lib/prisma'
import { verifyToken, getTokenFromReq } from '../../../lib/auth'
export default async function handler(req,res){
 const token=getTokenFromReq(req)
 const data=token?verifyToken(token):null
 if(!data || data.role!=='admin') return res.status(403).json({error:'Admin only'})
 const users=await prisma.user.findMany({select:{id:true,email:true,role:true,name:true,createdAt:true}})
 res.json({users})
}
EOF

cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = { reactStrictMode: true }
module.exports = nextConfig
EOF

echo "✅ Alle Dateien erstellt"
ls -R
cp.env.example.env
nano.env
pwd
cat > .env << 'EOF'
DATABASE_URL="postgresql://neondb_owner:DEIN_PASSWORT@ep-still-field-03608854-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require"
GONKA_API_KEY="gkr_DEIN_KEY_VON_GONKAROUTER"
JWT_SECRET="mein_super_langer_secret_key_mindestens_32_zeichen_123456789"
ADMIN_EMAIL="admin@ai-sandbox.pro"
EOF

cat .env
cd ~/ai-sandbox-backend
cat > .env << 'EOF'
DATABASE_URL="postgresql://neondb_owner:npg_9bidSFETJXV0@ep-bitter-smoke-b1h793f6-pooler.c-5.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
GONKA_API_KEY="sk-zzhnm2DufRo7K2A68Po6koJbEOy1VnUcxvgrF6r75qny9LKq"
JWT_SECRET="supersecret1234567890supersecret"
EOF

npx prisma db push
cd ~/ai-sandbox-backend
# 1. libsql aus package.json entfernen (brauchen wir nicht)
cat > package.json << 'EOF'
{
  "name": "ai-sandbox-backend",
  "version": "4.2.0",
  "scripts": { "dev": "next dev", "build": "next build", "start": "next start" },
  "dependencies": {
    "next": "^14.2.0",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "@prisma/client": "^5.13.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2"
  },
  "devDependencies": {
    "prisma": "^5.13.0"
  }
}
EOF

# 2. Cache + node_modules löschen
rm -rf node_modules package-lock.json
# 3. Mit --force installieren (ignoriert Android Check)
npm install --force
# 4. Alternative falls es nochmal meckert:
npm config set os linux
npm install --force
npm config delete os
cd ~/ai-sandbox-backend
cat > .env << 'EOF'
DATABASE_URL="postgresql://neondb_owner:npg_9bidSFETJXV0@ep-bitter-smoke-b1h793f6-pooler.c-5.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
GONKA_API_KEY="sk-zzhnm2DufRo7K2A68Po6koJbEOy1VnUcxvgrF6r75qny9LKq"
JWT_SECRET="supersecret1234567890supersecret"
EOF

npx prisma db push
npm install --force
npx prisma generate
rm prisma/schema.prisma
cat > prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

model User {
  id String @id @default(cuid())
  name String
  email String @unique
  password String
  role String @default("user")
  createdAt DateTime @default(now())
  prompts Prompt[]
  logs Log[]
}

model Prompt {
  id String @id @default(cuid())
  userId String
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
  title String
  prompt String
  createdAt DateTime @default(now())
}

model Log {
  id String @id @default(cuid())
  userId String?
  user User? @relation(fields: [userId], references: [id])
  action String
  model String?
  tokens Int?
  createdAt DateTime @default(now())
}

model SystemSetting {
  id String @id @default("global")
  defaultModel String @default("Qwen3-235B-A22B-Instruct-2507-FP8")
  pricingPer1M Float @default(0.0004)
  updatedAt DateTime @updatedAt
}
EOF

cat prisma/schema.prisma
npx prisma generate
npx prisma db push
# In Termux Haupt-Termux:
pkg update -y
pkg install proot-distro -y
proot-distro install ubuntu
proot-distro login ubuntu
# 2. Du bist jetzt wieder in normalem Termux (Prompt: ~ $)
# Prüfen:
pwd
# sollte /data/data/com.termux/files/home sein
# 3. Jetzt Ubuntu neu starten – OHNE verschachtelung
proot-distro login ubuntu
exit
npm i -g neon@latest
neon --version
neon login
neon link --project-id still-field-03608854 --branch production -y
neon config init
cd ai-sandbox
proot-distro login ubuntu
# In Ubuntu:
cd /root/ai-sandbox-backend
cat > package.json << 'EOF'
{
  "name": "ai-sandbox-backend",
  "version": "4.2.0",
  "scripts": { "dev": "next dev" },
  "dependencies": {
    "next": "14.2.0",
    "react": "18.3.1",
    "react-dom": "18.3.1",
    "@prisma/client": "5.13.0",
    "bcryptjs": "2.4.3",
    "jsonwebtoken": "9.0.2"
  },
  "devDependencies": { "prisma": "5.13.0" }
}
EOF

# Jetzt git push – Vercel baut
git init
git remote add origin https://github.com/jodaaisupport-commits/ai-sandbox.git
git add .
git commit -m "fix: ubuntu build"
git push origin main --force
