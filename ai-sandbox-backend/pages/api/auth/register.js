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
