import { prisma } from '../../../lib/prisma'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
export default async function handler(req,res){
 if(req.method!=='POST') return res.status(405).end()
 const {email,password}=req.body
 const user=await prisma.user.findUnique({where:{email}})
 if(!user) return res.status(401).json({error:'User not found'})
 const ok=await bcrypt.compare(password,user.password)
 if(!ok) return res.status(401).json({error:'Wrong password'})
 const token=jwt.sign({id:user.id,role:user.role},process.env.JWT_SECRET,{expiresIn:'7d'})
 res.json({token,user:{id:user.id,email:user.email,role:user.role}})
}
