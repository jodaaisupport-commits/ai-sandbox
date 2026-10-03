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
