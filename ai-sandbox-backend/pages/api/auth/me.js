import { verifyToken, getTokenFromReq } from '../../../lib/auth'
import { prisma } from '../../../lib/prisma'
export default async function handler(req,res){
 const token=getTokenFromReq(req)
 const data=token?verifyToken(token):null
 if(!data) return res.status(401).json({error:'Unauthorized'})
 const user=await prisma.user.findUnique({where:{id:data.id}})
 res.json({user:{id:user.id, email:user.email, role:user.role, name:user.name}})
}
