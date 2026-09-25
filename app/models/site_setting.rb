class SiteSetting < ApplicationRecord
  FONTS = ['Bricolage Grotesque', 'DM Sans', 'Inter', 'Manrope', 'Space Grotesk', 'Outfit', 'Poppins', 'Montserrat', 'Roboto', 'Playfair Display', 'Fraunces', 'Lora'].freeze
  COLOR_NAMES = { 'bg' => 'Background', 'surface' => 'Surface', 'ink' => 'Text', 'muted' => 'Muted text', 'line' => 'Lines', 'accent' => 'Accent',
                  'accent_ink' => 'Text on accent', 'pop' => 'Highlight', 'pop_ink' => 'Text on highlight', 'ok' => 'Success' }.freeze
  LIGHT = %w[#ffffff #eef2f9 #0d1a2f #55627a #d9e0ec #2444f5 #ffffff #e4ff4f #0d1a2f #0a7a45].freeze
  DARK  = %w[#0a1220 #111c31 #eef2fa #9aa8c2 #22304a #6f86ff #0a1220 #e4ff4f #0d1a2f #4ade9a].freeze

  DEFAULTS = {
    'name1' => 'Simple', 'name2' => 'Mobile', 'title' => 'SimpleMobile – Unlimited mobile service for $25/month',
    'theme' => 'auto', 'font_display' => 'Bricolage Grotesque', 'font_body' => 'DM Sans', 'radius' => '24',
    'hero_headline' => 'Premium mobile service, without the premium bill.',
    'hero_lede' => 'Unlimited talk, text, and data on a nationwide network. No contracts, no hidden fees, no hassle.',
    'hero_btn1' => 'Start your service', 'hero_btn2' => "See what's included",
    'hero_note' => 'per month, taxes and fees included', 'hero_small' => 'One-time $3 SIM fee at signup',
    'features_heading' => "Everything you need. Nothing you don't.",
    'plan_heading' => 'One plan. One price.',
    'plan_lede' => 'No tiers and no fine print. Pick it, use it, cancel whenever you like. Compared with major carriers, that can save you up to $600 a year.',
    'plan_name' => 'Unlimited plan', 'plan_currency' => '$', 'plan_price' => '25', 'plan_period' => '/ month',
    'plan_cta' => 'Get started', 'plan_fine' => 'First month + SIM card: $28 today.',
    'steps_heading' => 'Get connected in three steps.', 'faq_heading' => 'Questions, answered.',
    'cta_heading' => 'Ready to pay less for mobile?', 'cta_btn' => 'Get started for $25/month',
    'footer_copy' => '© 2026 SimpleMobile. All rights reserved.',
    'co_title' => 'Start your service', 'co_sub' => 'First month + SIM card: $28, then $25/month.', 'co_submit' => 'Pay $28 and order',
    'co_done_title' => "You're in.", 'co_done_text' => 'Your SIM ships in 2–3 business days. Activation steps are on their way to your email.'
  }.merge(
    COLOR_NAMES.keys.each_with_index.to_h { |c, i| ["l_#{c}", LIGHT[i]] },
    COLOR_NAMES.keys.each_with_index.to_h { |c, i| ["d_#{c}", DARK[i]] }
  ).freeze

  T = ->(k, l, t = :text, o = nil) { [k, l, t, o] }
  FIELDS = [
    ['Brand', [T['name1', 'Name, first part'], T['name2', 'Name, accent part'], T['title', 'Browser tab title'],
               T['theme', 'Color mode', :select, %w[auto light dark]], T['font_display', 'Heading font', :select, FONTS],
               T['font_body', 'Body font', :select, FONTS], T['radius', 'Corner radius (px, 0-60)']]],
    ['Light colors', COLOR_NAMES.map { |c, l| T["l_#{c}", l, :color] }],
    ['Dark colors', COLOR_NAMES.map { |c, l| T["d_#{c}", l, :color] }],
    ['Hero', [T['hero_headline', 'Headline', :area], T['hero_lede', 'Intro text', :area], T['hero_btn1', 'Primary button'],
              T['hero_btn2', 'Secondary button'], T['hero_note', 'Price caption'], T['hero_small', 'Small print']]],
    ['Section headings', [T['features_heading', 'Features'], T['steps_heading', 'Steps'], T['faq_heading', 'FAQ'], T['cta_heading', 'Final call to action'], T['cta_btn', 'Final button']]],
    ['Plan', [T['plan_heading', 'Section heading'], T['plan_lede', 'Intro text', :area], T['plan_name', 'Plan name'], T['plan_currency', 'Currency symbol'],
              T['plan_price', 'Price'], T['plan_period', 'Period label'], T['plan_cta', 'Button label'], T['plan_fine', 'Small print']]],
    ['Checkout dialog', [T['co_title', 'Title'], T['co_sub', 'Subtitle'], T['co_submit', 'Button'], T['co_done_title', 'Success title'], T['co_done_text', 'Success text', :area]]],
    ['Footer', [T['footer_copy', 'Copyright line']]]
  ].freeze

  def self.values = DEFAULTS.merge(pluck(:key, :value).to_h)

  def self.store(k, v)
    return unless DEFAULTS.key?(k)
    v = v.to_s.strip
    v = DEFAULTS[k] if k.match?(/\A[ld]_/) && !v.match?(/\A#\h{3,8}\z/)
    v = DEFAULTS[k] if k.start_with?('font_') && !FONTS.include?(v)
    v = DEFAULTS[k] if k == 'theme' && !%w[auto light dark].include?(v)
    v = v.to_i.clamp(0, 60).to_s if k == 'radius'
    find_or_initialize_by(key: k).update!(value: v)
  end
end
