STATIC_SITE_CSS = <<~CSS.freeze
:root{box-sizing:border-box;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth;scroll-padding-top:calc(72px + env(safe-area-inset-top,0px))}
body{background:var(--bg);color:var(--ink);font:400 1.0625rem/1.6 var(--body);-webkit-font-smoothing:antialiased}
a{color:inherit}
:focus-visible{outline:3px solid var(--blue);outline-offset:3px;border-radius:4px}
.wrap{max-width:1120px;margin:0 auto;padding:0 1.5rem}
h1,h2,h3{font-family:var(--display);line-height:1.05;letter-spacing:-.025em}
h2{font-size:clamp(2rem,4.5vw,3.25rem);font-weight:800;max-width:16ch}
.lede{color:var(--muted);max-width:52ch}
.btn{display:inline-flex;align-items:center;justify-content:center;font:700 1rem var(--body);padding:.95rem 1.6rem;border-radius:999px;border:0;background:var(--blue);color:var(--blue-ink);text-decoration:none;cursor:pointer;transition:transform .15s,opacity .15s}
.btn:hover{transform:translateY(-1px);opacity:.92}
.btn.ghost{background:transparent;color:var(--ink);box-shadow:inset 0 0 0 1.5px var(--line)}
.btn.sm{padding:.55rem 1.1rem;font-size:.9rem}
header{position:sticky;top:env(safe-area-inset-top,0px);z-index:20;background:color-mix(in srgb,var(--bg) 88%,transparent);backdrop-filter:blur(12px);border-bottom:1px solid var(--line)}
header .wrap{display:flex;align-items:center;justify-content:space-between;height:64px}
.logo{font:800 1.35rem var(--display);letter-spacing:-.03em;text-decoration:none}
.logo i{font-style:normal;color:var(--blue)}
nav{display:flex;gap:1.75rem;align-items:center}
nav a:not(.btn){text-decoration:none;color:var(--muted);font-weight:500}
nav a:not(.btn):hover{color:var(--ink)}
.hero{padding:clamp(3rem,8vw,6.5rem) 0 clamp(3rem,7vw,5rem)}
.hero .wrap{display:grid;grid-template-columns:1.15fr .85fr;gap:3rem;align-items:center}
.hero h1{font-size:clamp(2.6rem,6.2vw,4.9rem);font-weight:800;margin-bottom:1.5rem}
.hero .lede{font-size:1.2rem;margin-bottom:2rem}
.actions{display:flex;gap:.75rem;flex-wrap:wrap}
.price-block{background:var(--pop);color:var(--pop-ink);border-radius:32px;padding:2.25rem 2rem;transform:rotate(2deg)}
.price-block .big{font:800 clamp(6rem,15vw,10.5rem)/.85 var(--display);letter-spacing:-.06em;display:flex;align-items:flex-start}
.price-block .big sup{font-size:.36em;margin:.12em .06em 0 0;letter-spacing:0}
.price-block p{font:700 1.15rem var(--display);margin-top:1rem}
.price-block small{display:block;font-weight:500;opacity:.75;font-family:var(--body);font-size:.95rem;margin-top:.25rem}
.strip{border-block:1px solid var(--line)}
.strip ul{list-style:none;display:flex;flex-wrap:wrap;justify-content:space-between;gap:.75rem 2rem;padding:1.15rem 0;font-weight:500}
.strip li::before{content:"\\2713";color:var(--ok);font-weight:800;margin-right:.55rem}
section.block{padding:clamp(4rem,8vw,7rem) 0}
.feat-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:0;margin-top:3rem;border-top:1px solid var(--line)}
.feat{padding:1.75rem 1.5rem 2rem 0;border-bottom:1px solid var(--line)}
.feat:not(:nth-child(3n)){padding-right:2rem}
.feat h3{font-size:1.35rem;font-weight:700;margin-bottom:.5rem;letter-spacing:-.02em}
.feat p{color:var(--muted)}
.plan{background:var(--surface)}
.plan .wrap{display:grid;grid-template-columns:1fr 1fr;gap:3rem;align-items:center}
.ticket{background:var(--bg);border:1.5px solid var(--ink);border-radius:var(--r,24px);padding:2.25rem}
.ticket .amt{font:800 4.5rem/1 var(--display);letter-spacing:-.05em}
.ticket .amt span{font-size:1.1rem;font-weight:500;letter-spacing:0;color:var(--muted);font-family:var(--body)}
.ticket ul{list-style:none;margin:1.5rem 0 2rem;border-top:1px solid var(--line)}
.ticket li{padding:.7rem 0;border-bottom:1px solid var(--line);display:flex;gap:.7rem}
.ticket li::before{content:"\\2713";color:var(--ok);font-weight:800}
.ticket .btn{width:100%}
.fine{font-size:.9rem;color:var(--muted);margin-top:.9rem;text-align:center}
.steps{list-style:none;counter-reset:s;margin-top:3rem;display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:2rem}
.steps li{counter-increment:s;border-top:3px solid var(--ink);padding-top:1.1rem}
.steps li::before{content:counter(s);font:800 3rem/1 var(--display);color:var(--blue);display:block;margin-bottom:.6rem}
.steps h3{font-size:1.3rem;margin-bottom:.4rem}
.steps p{color:var(--muted)}
.faq{background:var(--surface)}
.faq .wrap{display:grid;grid-template-columns:.8fr 1.2fr;gap:3rem}
details{border-bottom:1px solid var(--line)}
details:first-of-type{border-top:1px solid var(--line)}
summary{list-style:none;cursor:pointer;padding:1.25rem 0;font:700 1.15rem var(--display);letter-spacing:-.01em;display:flex;justify-content:space-between;gap:1rem}
summary::-webkit-details-marker{display:none}
summary::after{content:"+";font-weight:500;font-size:1.5rem;line-height:1;transition:transform .2s}
details[open] summary::after{transform:rotate(45deg)}
details p{color:var(--muted);padding:0 2rem 1.4rem 0}
.final{background:var(--blue);color:var(--blue-ink);text-align:left}
.final .wrap{display:flex;justify-content:space-between;align-items:center;gap:2rem;flex-wrap:wrap}
.final h2{max-width:14ch}
.final .btn{background:var(--pop);color:var(--pop-ink)}
footer{padding:2.5rem 0;color:var(--muted);font-size:.95rem}
footer .wrap{display:flex;justify-content:space-between;gap:1.5rem;flex-wrap:wrap}
footer nav{gap:1.25rem;flex-wrap:wrap}
dialog{border:0;border-radius:24px;padding:2rem;width:min(460px,92vw);background:var(--bg);color:var(--ink);margin:auto}
dialog::backdrop{background:rgba(5,10,20,.65);backdrop-filter:blur(3px)}
dialog h2{font-size:1.8rem;margin-bottom:.4rem}
dialog .sub{color:var(--muted);margin-bottom:1.5rem}
.field{margin-bottom:1rem}
.field label{display:block;font-weight:700;font-size:.95rem;margin-bottom:.35rem}
.field input{width:100%;font:inherit;padding:.75rem .9rem;border-radius:10px;border:1.5px solid var(--line);background:var(--bg);color:var(--ink)}
.field input:focus{outline:none;border-color:var(--blue);box-shadow:0 0 0 3px rgba(36,68,245,.25)}
.close{position:absolute;top:.8rem;right:1rem;background:none;border:0;font-size:1.8rem;color:var(--muted);cursor:pointer}
.done{display:none}
dialog.ok form,dialog.ok .sub{display:none}
dialog.ok .done{display:block}
@media (max-width:820px){
  nav a:not(.btn){display:none}
  .hero .wrap,.plan .wrap,.faq .wrap{grid-template-columns:1fr}
  .price-block{transform:none}
  .feat-grid,.steps{grid-template-columns:1fr}
  .feat{padding-right:0!important}
  .strip ul{justify-content:flex-start}
}
@media (prefers-reduced-motion:reduce){*{transition:none!important;scroll-behavior:auto!important}}
CSS
