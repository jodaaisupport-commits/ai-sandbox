import { prisma } from '../../../lib/prisma'
import bcrypt from 'bcryptjs'
export default async function handler(req,res){
 if(req.method!=='POST') return res.status(405).end()
 const {name,email,password}=req.body
 const hash=await bcrypt.hash(password,10)
 try{
  const user=await prisma.user.create({data:{name,email,password:hash}})
  res.json({id:user.id})
 }catch(e){ res.status(400).json({error:'Email exists'}) }
}
