import jwt from 'jsonwebtoken'
import bcrypt from 'bcryptjs'
const SECRET = process.env.JWT_SECRET || 'dev-secret'
export const signToken = (u) => jwt.sign({id:u.id, email:u.email, role:u.role}, SECRET, {expiresIn:'7d'})
export const verifyToken = (t) => { try{return jwt.verify(t, SECRET)}catch{return null} }
export const hashPassword = (pw) => bcrypt.hash(pw, 10)
export const comparePassword = (pw, hash) => bcrypt.compare(pw, hash)
export const getTokenFromReq = (req) => { const a=req.headers.authorization||''; return a.startsWith('Bearer ')?a.slice(7):null }
