// Scroll reveal
const io = new IntersectionObserver((entries)=>{
  entries.forEach(e=>{ if(e.isIntersecting){ e.target.classList.add('show'); io.unobserve(e.target);} });
},{threshold:.12});
document.querySelectorAll('.reveal').forEach((el,i)=>{ el.style.transitionDelay=(i%3*60)+'ms'; io.observe(el); });

// 신청 폼 처리는 form.js 로 이동 (구글 시트 "과외" 탭 연결)

/* 공용 페이지네이션: paginate(리스트, 아이템, 페이저, 페이지당개수) */
function paginate(listSel, itemSel, pagerSel, per){
  const list = document.querySelector(listSel);
  const pager = document.querySelector(pagerSel);
  if(!list || !pager) return;
  const items = [...list.querySelectorAll(itemSel)];
  if(items.length <= per){ pager.style.display='none'; items.forEach(i=>i.classList.add('show')); return; }
  const pages = Math.ceil(items.length / per);
  let page = 1;
  function build(){
    let h = `<button ${page===1?'disabled':''} data-p="${page-1}">‹</button>`;
    const win = [];
    for(let p=1;p<=pages;p++){
      if(p===1 || p===pages || (p>=page-1 && p<=page+1)) win.push(p);
      else if(win[win.length-1] !== '...') win.push('...');
    }
    win.forEach(p=>{
      h += (p==='...') ? '<span class="dots">…</span>'
        : `<button class="${p===page?'active':''}" data-p="${p}">${p}</button>`;
    });
    h += `<button ${page===pages?'disabled':''} data-p="${page+1}">›</button>`;
    pager.innerHTML = h;
  }
  function show(scroll){
    items.forEach((el,i)=>{
      const on = i >= (page-1)*per && i < page*per;
      el.style.display = on ? '' : 'none';
      if(on) el.classList.add('show');
    });
    build();
    if(scroll) window.scrollTo({top: list.getBoundingClientRect().top + window.scrollY - 110, behavior:'smooth'});
  }
  pager.addEventListener('click', e=>{
    const b = e.target.closest('button'); if(!b || b.disabled) return;
    const p = parseInt(b.dataset.p,10);
    if(p>=1 && p<=pages){ page = p; show(true); }
  });
  show(false);
}
