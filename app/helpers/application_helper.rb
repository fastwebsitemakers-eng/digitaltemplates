module ApplicationHelper
  CSSVAR = { 'accent' => 'blue', 'accent_ink' => 'blue-ink', 'pop_ink' => 'pop-ink' }.freeze

  def list(kind) = ContentItem.of(kind)

  # Values are validated in SiteSetting.store (hex colors, whitelisted fonts, integer radius).
  def theme_css(s)
    vars = ->(p) { SiteSetting::COLOR_NAMES.keys.map { |c| "--#{CSSVAR.fetch(c, c)}:#{s["#{p}_#{c}"]}" }.join(';') }
    "@import url('#{font_url(s)}');:root{#{vars['l']};--display:'#{s['font_display']}';--body:'#{s['font_body']}';--r:#{s['radius'].to_i}px}" \
    "@media (prefers-color-scheme:dark){:root[data-theme=\"auto\"]{#{vars['d']}}}:root[data-theme=\"dark\"]{#{vars['d']}}"
  end

  def font_url(s)
    fams = [s['font_display'], s['font_body']].uniq.map { |f| "family=#{f.tr(' ', '+')}:wght@400;500;700" }
    "https://fonts.googleapis.com/css2?#{fams.join('&')}&display=swap"
  end
end
