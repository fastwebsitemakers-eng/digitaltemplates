class SiteExport
  COLOR_JSON = { 'bg' => 'bg', 'surface' => 'surface', 'ink' => 'ink', 'muted' => 'muted', 'line' => 'line',
                 'accent' => 'accent', 'accentInk' => 'accent_ink', 'pop' => 'pop', 'popInk' => 'pop_ink', 'ok' => 'ok' }.freeze

  def self.to_hash
    s = SiteSetting.values
    pal = ->(pfx) { COLOR_JSON.to_h { |jk, rk| [jk, s["#{pfx}_#{rk}"]] } }
    {
      'site' => { 'name1' => s['name1'], 'name2' => s['name2'], 'title' => s['title'] },
      'theme' => s['theme'], 'radius' => s['radius'].to_i,
      'fonts' => { 'display' => s['font_display'], 'body' => s['font_body'] },
      'colors' => { 'light' => pal.call('l'), 'dark' => pal.call('d') },
      'hero' => { 'headline' => s['hero_headline'], 'lede' => s['hero_lede'], 'btn1' => s['hero_btn1'],
                  'btn2' => s['hero_btn2'], 'priceNote' => s['hero_note'], 'small' => s['hero_small'] },
      'strip' => ContentItem.of('strip').map { |i| { 't' => i.title } },
      'features' => { 'heading' => s['features_heading'],
                       'items' => ContentItem.of('feature').map { |i| { 'title' => i.title, 'text' => i.body } } },
      'plan' => { 'heading' => s['plan_heading'], 'lede' => s['plan_lede'], 'name' => s['plan_name'], 'currency' => s['plan_currency'],
                  'price' => s['plan_price'], 'period' => s['plan_period'], 'cta' => s['plan_cta'], 'fine' => s['plan_fine'],
                  'items' => ContentItem.of('plan_item').map { |i| { 't' => i.title } } },
      'steps' => { 'heading' => s['steps_heading'],
                   'items' => ContentItem.of('step').map { |i| { 'title' => i.title, 'text' => i.body } } },
      'faq' => { 'heading' => s['faq_heading'],
                 'items' => ContentItem.of('faq').map { |i| { 'q' => i.title, 'a' => i.body } } },
      'cta' => { 'heading' => s['cta_heading'], 'btn' => s['cta_btn'] },
      'footer' => { 'copy' => s['footer_copy'],
                    'links' => ContentItem.of('footer_link').map { |i| { 't' => i.title, 'href' => i.body } } },
      'checkout' => { 'title' => s['co_title'], 'sub' => s['co_sub'], 'submit' => s['co_submit'],
                       'doneTitle' => s['co_done_title'], 'doneText' => s['co_done_text'] }
    }
  end

  def self.apply(j)
    site = j['site'] || {}
    %w[name1 name2 title].each { |k| SiteSetting.store(k, site[k]) if site[k] }
    SiteSetting.store('theme', j['theme']) if j['theme']
    SiteSetting.store('radius', j['radius']) if j['radius']
    fonts = j['fonts'] || {}
    SiteSetting.store('font_display', fonts['display']) if fonts['display']
    SiteSetting.store('font_body', fonts['body']) if fonts['body']
    colors = j['colors'] || {}
    { 'light' => 'l', 'dark' => 'd' }.each do |src, pfx|
      pal = colors[src] || {}
      COLOR_JSON.each { |jk, rk| SiteSetting.store("#{pfx}_#{rk}", pal[jk]) if pal[jk] }
    end
    hero = j['hero'] || {}
    { 'headline' => 'hero_headline', 'lede' => 'hero_lede', 'btn1' => 'hero_btn1', 'btn2' => 'hero_btn2',
      'priceNote' => 'hero_note', 'small' => 'hero_small' }.each { |jk, rk| SiteSetting.store(rk, hero[jk]) if hero[jk] }
    feat = j['features'] || {}
    SiteSetting.store('features_heading', feat['heading']) if feat['heading']
    plan = j['plan'] || {}
    { 'heading' => 'plan_heading', 'lede' => 'plan_lede', 'name' => 'plan_name', 'currency' => 'plan_currency',
      'price' => 'plan_price', 'period' => 'plan_period', 'cta' => 'plan_cta', 'fine' => 'plan_fine' }.each { |jk, rk| SiteSetting.store(rk, plan[jk]) if plan[jk] }
    steps = j['steps'] || {}
    SiteSetting.store('steps_heading', steps['heading']) if steps['heading']
    faq = j['faq'] || {}
    SiteSetting.store('faq_heading', faq['heading']) if faq['heading']
    cta = j['cta'] || {}
    SiteSetting.store('cta_heading', cta['heading']) if cta['heading']
    SiteSetting.store('cta_btn', cta['btn']) if cta['btn']
    footer = j['footer'] || {}
    SiteSetting.store('footer_copy', footer['copy']) if footer['copy']
    co = j['checkout'] || {}
    { 'title' => 'co_title', 'sub' => 'co_sub', 'submit' => 'co_submit',
      'doneTitle' => 'co_done_title', 'doneText' => 'co_done_text' }.each { |jk, rk| SiteSetting.store(rk, co[jk]) if co[jk] }

    replace('strip', (j['strip'] || []).map { |i| [i['t'], nil] })
    replace('feature', (feat['items'] || []).map { |i| [i['title'], i['text']] })
    replace('plan_item', (plan['items'] || []).map { |i| [i['t'], nil] })
    replace('step', (steps['items'] || []).map { |i| [i['title'], i['text']] })
    replace('faq', (faq['items'] || []).map { |i| [i['q'], i['a']] })
    replace('footer_link', (footer['links'] || []).map { |i| [i['t'], i['href']] })
  end

  def self.replace(kind, pairs)
    return if pairs.empty?
    ContentItem.where(kind: kind).delete_all
    pairs.each { |t, b| ContentItem.create!(kind: kind, title: t.to_s, body: b.to_s) if t.present? }
  end
end