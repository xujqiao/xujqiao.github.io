{%- if theme.footer.beian.enable %}
  <div class="beian">
    {{- next_url('https://beian.miit.gov.cn', theme.footer.beian.icp + ' ') }}
    {%- if theme.footer.beian.gongan_icon_url %}
      <img src="{{ url_for(theme.footer.beian.gongan_icon_url) }}" style="display: inline-block;">
    {%- endif %}
    {%- if theme.footer.beian.gongan_id and theme.footer.beian.gongan_num %}
      {{- next_url('http://www.beian.gov.cn/portal/registerSystemInfo?recordcode=' + theme.footer.beian.gongan_id, theme.footer.beian.gongan_num + ' ') }}
    {%- endif %}
  </div>
{%- endif %}

<div class="copyright">
  {% set copyright_year = date(null, 'YYYY') %}
  &copy; {% if theme.footer.since and theme.footer.since != copyright_year %}{{ theme.footer.since }} &ndash; {% endif %}
  <span itemprop="copyrightYear">{{ copyright_year }}</span>
  <span class="with-love">
    <i class="{{ theme.footer.icon.name }}"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ theme.footer.copyright or author }}</span>

  {%- if config.symbols_count_time.total_symbols %}
    <span class="post-meta-divider">|</span>
    <span class="post-meta-item-icon">
      <i class="fa fa-chart-area"></i>
    </span>
    {%- if theme.symbols_count_time.item_text_total %}
      <span class="post-meta-item-text">{{ __('symbols_count_time.count_total') + __('symbol.colon') }}</span>
    {%- endif %}
    <span title="{{ __('symbols_count_time.count_total') }}">{{ symbolsCountTotal(site) }}</span>
  {%- endif %}

  {%- if config.symbols_count_time.total_time %}
    <span class="post-meta-divider">|</span>
    <span class="post-meta-item-icon">
      <i class="fa fa-coffee"></i>
    </span>
    {%- if theme.symbols_count_time.item_text_total %}
      <span class="post-meta-item-text">{{ __('symbols_count_time.time_total') }} &asymp;</span>
    {%- endif %}
    <span title="{{ __('symbols_count_time.time_total') }}">{{ symbolsTimeTotal(site, config.symbols_count_time.awl, config.symbols_count_time.wpm, __('symbols_count_time.time_minutes')) }}</span>
  {%- endif %}
</div>

{%- if theme.footer.powered %}
  <div class="powered-by">
    {%- set next_site = 'https://theme-next.org' %}
    {%- if theme.scheme !== 'Gemini' %}
      {%- set next_site = 'https://' + theme.scheme | lower + '.theme-next.org' %}
    {%- endif %}
    {{- __('footer.powered', next_url('https://hexo.io', 'Hexo', {class: 'theme-link'}) + ' & ' + next_url(next_site, 'NexT.' + theme.scheme, {class: 'theme-link'})) }}
  </div>
{%- endif %}

{%- if theme.add_this_id %}
  <div class="addthis_inline_share_toolbox">
    <script src="//s7.addthis.com/js/300/addthis_widget.js#pubid={{ theme.add_this_id }}" async="async"></script>
  </div>
{%- endif %}

{{- next_inject('footer') }}

<script>
(function(){
  // Track visit
  try {
    var hm=JSON.parse(localStorage.getItem('hm')||'{}');
    var today=new Date().toISOString().slice(0,10);
    hm[today]=(hm[today]||0)+1;
    localStorage.setItem('hm',JSON.stringify(hm));
  } catch(e){}

  // Show on homepage only (including paginated pages)
  var pn=window.location.pathname;
  if(pn!=='/' && pn!=='/index.html' && !/^\/page\/\d+\/$/.test(pn)) return;

  function render(){
    var box=document.createElement('div');
    box.style.cssText='max-width:760px;margin:24px auto 12px;padding:0 15px;';
    box.innerHTML=
      '<div style="background:#fafaf8;border-radius:12px;padding:20px 28px;">'+
        '<div style="font-size:13px;color:#999;margin-bottom:14px;letter-spacing:1px;text-align:center;">&#10022; 活动记录</div>'+
        '<div id="hmgrid" style="display:grid;grid-template-columns:repeat(53,1fr);gap:2px;width:100%;"></div>'+
        '<div style="margin-top:10px;font-size:11px;color:#999;text-align:right;">'+
          '<span id="hmstat"></span>'+
        '</div>'+
      '</div>';
    var footer=document.querySelector('.copyright');
    if(footer) footer.parentNode.insertBefore(box, footer);

    var grid=document.getElementById('hmgrid');
    var today=new Date();
    var cs=['#ebedf0','#9be9a8','#40c463','#30a14e','#216e39'];
    var total=0,streak=0,cur=0;

    // Get visit data
    var visits={};
    try { visits=JSON.parse(localStorage.getItem('hm')||'{}'); } catch(e){}

    var startD=new Date(today);startD.setDate(startD.getDate()-364);
    var startDow=startD.getDay();
    var html='';
    for(var i=0;i<startDow;i++) html+='<div></div>';

    for(var i=364;i>=0;i--){
      var d=new Date(today);d.setDate(d.getDate()-i);
      var key=d.toISOString().slice(0,10);
      var v=visits[key]||0;
      var level=v===0?0:v<=2?1:v<=6?2:v<=15?3:4;
      html+='<div title="'+key+': '+v+' 次访问" style="aspect-ratio:1;background:'+cs[level]+';border-radius:2px;"></div>';
      total+=v;
      if(v>0){cur++;streak=Math.max(streak,cur);}else cur=0;
    }
    var remain=(7-(365+startDow)%7)%7;
    for(var i=0;i<remain;i++) html+='<div></div>';
    grid.innerHTML=html;

    document.getElementById('hmstat').textContent='累计 '+total+' 次访问 / 最长连续 '+streak+' 天';
  }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',render);
  else render();
})();
</script>
