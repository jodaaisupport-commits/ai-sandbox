import { prisma } from '../../../lib/prisma'
import { verifyToken, getTokenFromReq } from '../../../lib/auth'
export default async function handler(req,res){
 const token=getTokenFromReq(req)
 const data=token?verifyToken(token):null
 if(!data || data.role!=='admin') return res.status(403).json({error:'Admin only'})
 const users=await prisma.user.findMany({select:{id:true,email:true,role:true,name:true,createdAt:true}})
 res.json({users})
}
