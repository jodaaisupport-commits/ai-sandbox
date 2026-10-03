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
