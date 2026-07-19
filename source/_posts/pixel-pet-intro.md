---
title: 我养了一只像素宠物
date: 2026-07-19 15:10:00
tags: [像素宠物, 趣味]
categories: 随笔
---

最近像素宠物挺火的，我也写了一个。

一个会饿、会困、会开心到蹦起来的像素小猫。

<!-- more -->

<div class="pet-embed" style="background:#f8f4ee;border-radius:16px;padding:24px;text-align:center;max-width:420px;margin:20px auto;">
  <canvas id="inlinePet" width="240" height="240" style="display:block;margin:0 auto;border-radius:10px;background:#f8f4ee;image-rendering:pixelated;width:240px;height:240px;"></canvas>
  <div style="display:flex;justify-content:space-between;gap:6px;margin:14px 0;">
    <div style="flex:1;text-align:center;"><div style="font-size:11px;color:#999;margin-bottom:3px;">饱食</div><div style="height:6px;background:#eee;border-radius:3px;overflow:hidden;"><div id="ihBar" style="height:100%;width:70%;background:#e8884a;border-radius:3px;transition:width 0.5s;"></div></div></div>
    <div style="flex:1;text-align:center;"><div style="font-size:11px;color:#999;margin-bottom:3px;">快乐</div><div style="height:6px;background:#eee;border-radius:3px;overflow:hidden;"><div id="ipBar" style="height:100%;width:60%;background:#6abf69;border-radius:3px;transition:width 0.5s;"></div></div></div>
    <div style="flex:1;text-align:center;"><div style="font-size:11px;color:#999;margin-bottom:3px;">精力</div><div style="height:6px;background:#eee;border-radius:3px;overflow:hidden;"><div id="ieBar" style="height:100%;width:80%;background:#5b9bd5;border-radius:3px;transition:width 0.5s;"></div></div></div>
  </div>
  <div style="display:flex;gap:8px;justify-content:center;flex-wrap:wrap;">
    <button onclick="ifb.feed()" style="font-size:13px;padding:6px 16px;border:2px solid #ddd;border-radius:8px;background:#fff;cursor:pointer;color:#555;font-family:'Courier New',monospace;">🍗 喂食</button>
    <button onclick="ifb.pet()" style="font-size:13px;padding:6px 16px;border:2px solid #ddd;border-radius:8px;background:#fff;cursor:pointer;color:#555;font-family:'Courier New',monospace;">👋 抚摸</button>
    <button onclick="ifb.play()" style="font-size:13px;padding:6px 16px;border:2px solid #ddd;border-radius:8px;background:#fff;cursor:pointer;color:#555;font-family:'Courier New',monospace;">🎾 玩耍</button>
  </div>
  <div id="imsg" style="margin-top:10px;font-size:12px;color:#888;font-style:italic;min-height:18px;">点击按钮和它互动吧</div>
</div>

三条状态分别代表饱食度、快乐度和精力，会随时间慢慢下降。要是太久不理它，它会自己睡着。

<style>
.pet-embed { box-sizing:border-box; }
@media (max-width:480px){
  .pet-embed { padding:12px!important; border-radius:12px!important; }
  .pet-embed canvas { width:180px!important; height:180px!important; }
  .pet-embed button { font-size:12px!important; padding:8px 14px!important; min-width:80px; }
  .pet-embed .stat-label { font-size:10px!important; }
}
</style>

<script>
(function(){
  const c = document.getElementById('inlinePet');
  const ctx = c.getContext('2d');
  const P = 240/60;
  let h=70, p=60, e=80;
  let anim='idle', animT=0, fc=0, blinkT=0, blinking=false, earW=0, tailW=0, mOpen=false;

  function setMsg(t){ document.getElementById('imsg').textContent=t; }
  function updBar(id,v){ document.getElementById(id).style.width=v+'%'; }
  function setH(v){ h=Math.max(0,Math.min(100,v)); updBar('ihBar',h); save(); }
  function setP(v){ p=Math.max(0,Math.min(100,v)); updBar('ipBar',p); save(); }
  function setE(v){ e=Math.max(0,Math.min(100,v)); updBar('ieBar',e); save(); }
  function feed(){ setH(h+20); setE(e+5); anim='eat'; animT=30; setMsg('咕噜咕噜... 真好吃！'); }
  function pett(){ setP(p+15); setE(e-3); anim='happy'; animT=25; earW=8; setMsg('呼噜呼噜~ 好舒服！'); }
  function play(){ if(e<15){setMsg('有点累了，让我歇会儿...');return;} setP(p+20); setE(e-15); setH(h-5); anim='play'; animT=40; setMsg('好开心！蹦蹦跳跳！'); }

  window.ifb={feed,pett,pet:pett,play};

  function save(){ try{localStorage.setItem('pet_state',JSON.stringify({h,p,e,t:Date.now()}));}catch(e){} }
  function load(){
    try{
      const d=JSON.parse(localStorage.getItem('pet_state'));
      if(d){
        const elapsed=Math.floor((Date.now()-d.t)/1000);
        const decay=Math.floor(elapsed/3);
        h=Math.max(0,Math.min(100,(d.h||70)-decay));
        p=Math.max(0,Math.min(100,(d.p||60)-Math.floor(decay/2)));
        e=Math.max(0,Math.min(100,(d.e||80)-Math.floor(decay/2)));
        updBar('ihBar',h); updBar('ipBar',p); updBar('ieBar',e);
        if(h<10) setMsg('好久不见... 好饿啊...');
        else if(e<10) setMsg('好久不见... 好困啊...');
        else setMsg('你回来了！');
      }
    }catch(e){}
  }
  load();

  function px(x,y,co){ if(x<0||x>=60||y<0||y>=60)return; ctx.fillStyle=co; ctx.fillRect(x*P,y*P,P,P); }
  function circ(cx,cy,r,co){ for(let x=-r;x<=r;x++) for(let y=-r;y<=r;y++) if(x*x+y*y<=r*r) px(cx+x,cy+y,co); }
  function rect(x,y,w,h,co){ for(let i=0;i<w;i++) for(let j=0;j<h;j++) px(x+i,y+j,co); }

  const BC='#c68b59', BD='#a07040', BL='#f0d5b0', EC='#333', NC='#ff8899', EAC='#d49a6a', EAI='#f0b8b8';

  function draw(oy,ea,ta,mo,bl){
    const cx=30, cy=36+oy;
    for(let i=0;i<8;i++){ const tx=cx-10-i+Math.sin(ta+i*0.3)*3, ty=cy-8-i*1.5; circ(Math.round(tx),Math.round(ty),2,BD); }
    rect(cx-10,cy+5,5,7,BD); rect(cx+5,cy+5,5,7,BD); rect(cx-11,cy+11,7,3,EAI); rect(cx+4,cy+11,7,3,EAI);
    for(let dx=-10;dx<=10;dx++) for(let dy=-8;dy<=8;dy++){ if(Math.abs(dx)/10+Math.abs(dy)/8<1.1&&cy+dy>cy-2) px(cx+dx,cy+dy,BC); }
    for(let dx=-5;dx<=5;dx++) for(let dy=-1;dy<=5;dy++){ if(Math.abs(dx)/5+Math.abs(dy)/5<1) px(cx+dx,cy+dy+2,BL); }
    rect(cx-7,cy+7,4,6,BC); rect(cx+3,cy+7,4,6,BC); rect(cx-8,cy+12,6,3,EAI); rect(cx+2,cy+12,6,3,EAI);
    const hy=cy-10; circ(cx,hy,9,BC); circ(cx,hy+2,8,BC); circ(cx,hy+4,6,BL);
    circ(cx-8+Math.sin(ea)*2,hy-6-Math.cos(ea),3.5,EAC); circ(cx-8+Math.sin(ea)*2,hy-6-Math.cos(ea),2,EAI);
    circ(cx+8-Math.sin(ea)*2,hy-6+Math.cos(ea),3.5,EAC); circ(cx+8-Math.sin(ea)*2,hy-6+Math.cos(ea),2,EAI);
    if(bl){ rect(cx-4,hy-1,3,2,BD); rect(cx+1,hy-1,3,2,BD); } else {
      circ(cx-3,hy,2,'#fff'); circ(cx+3,hy,2,'#fff'); circ(cx-3,hy,1.2,EC); circ(cx+3,hy,1.2,EC); px(cx-2,hy-1,'#fff'); px(cx+4,hy-1,'#fff');
    }
    circ(cx,hy+3,1.5,NC);
    if(mo){ rect(cx-2,hy+5,4,2,'#d4707a'); } else { px(cx-1,hy+5,BD); px(cx+1,hy+5,BD); }
    circ(cx-6,hy+3,2.5,'#f0c8c8'); circ(cx+6,hy+3,2.5,'#f0c8c8');
    for(let i=-1;i<=1;i++){ px(cx-8,hy+3+i,'#ccc'); px(cx-10,hy+3+i,'#ccc'); px(cx-12,hy+2+i,'#ccc'); px(cx+8,hy+3+i,'#ccc'); px(cx+10,hy+3+i,'#ccc'); px(cx+12,hy+2+i,'#ccc'); }
    circ(cx-3,hy-6,1.5,BD); circ(cx+4,hy-5,1,BD);
  }

  function loop(){
    fc++;
    if(fc%180===0){ setH(h-2); setP(p-1); setE(e-1); }
    if(animT>0&&--animT===0) anim='idle';
    if(e<10&&anim==='idle'){ anim='sleep'; setMsg('zzz... 睡着了... 正在恢复精力...'); }
    if(e>=80&&anim==='sleep'){ anim='idle'; setMsg('睡饱了，精神十足！'); }
    // 睡觉时恢复精力
    if(anim==='sleep'&&fc%30===0) setE(e+2);
    blinkT++; if(!blinking&&blinkT>120+Math.random()*60){ blinking=true; blinkT=0; }
    if(blinking&&blinkT>6) blinking=false;
    if(earW>0) earW*=0.85; if(earW<0.1) earW=0;
    tailW=Math.sin(fc*0.05)*0.3; if(anim==='happy'||anim==='play') tailW=Math.sin(fc*0.12)*0.6;
    ctx.clearRect(0,0,240,240);
    ctx.fillStyle='#e8e0d6'; ctx.beginPath(); ctx.ellipse(120,210,70,10,0,0,Math.PI*2); ctx.fill();
    let oy=0, ea=earW*0.1, ta=tailW, mo=false, bl=blinking||anim==='sleep';
    switch(anim){
      case'idle': oy=Math.sin(fc*0.03)*0.3; ta=Math.sin(fc*0.05)*0.2; break;
      case'eat': oy=Math.sin(fc*0.3)*0.8; mo=fc%10<5; break;
      case'happy': oy=Math.sin(fc*0.2)*1.5; ea=Math.sin(fc*0.15)*0.3; mo=true; break;
      case'play': oy=Math.sin(fc*0.25)*2.5; ea=Math.sin(fc*0.2)*0.2; mo=true; break;
      case'sleep': oy=Math.sin(fc*0.02)*0.5; break;
    }
    draw(oy,ea,ta,mo,bl);
    if(anim==='sleep'){ ctx.fillStyle='#aaa'; ctx.font='10px "Courier New"'; ['z','Z','Z'].forEach((z,i)=>{ctx.globalAlpha=0.7-i*0.2;ctx.fillText(z,165+i*7,70-i*10+Math.sin(fc*0.03+i*2)*3);}); ctx.globalAlpha=1; }
    if(anim==='happy'){ for(let i=0;i<3;i++){ ctx.fillStyle='#ffd700'; ctx.globalAlpha=0.6; ctx.font='8px "Courier New"'; ctx.fillText('*',60+Math.sin(fc*0.1+i*2)*20,85+Math.cos(fc*0.08+i*1.5)*12); } ctx.globalAlpha=1; }
    requestAnimationFrame(loop);
  }
  loop();
  setInterval(()=>{ if(h<20&&anim==='idle') setMsg('好饿啊... 给点吃的吧...'); else if(p<20&&anim==='idle') setMsg('好无聊... 陪我玩会儿...'); },5000);
})();
</script>
