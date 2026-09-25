class ContentItem < ApplicationRecord
  KINDS = {
    'strip' => { label: 'Trust strip', t: 'Text' }, 'feature' => { label: 'Features', t: 'Title', b: 'Description' },
    'plan_item' => { label: 'Plan items', t: 'Text' }, 'step' => { label: 'Steps', t: 'Title', b: 'Description' },
    'faq' => { label: 'FAQ', t: 'Question', b: 'Answer' }, 'footer_link' => { label: 'Footer links', t: 'Label', b: 'Link (URL or #anchor)' }
  }.freeze
  validates :kind, inclusion: { in: KINDS.keys }
  validates :title, presence: true, length: { maximum: 200 }
  validates :body, length: { maximum: 2000 }
  validates :body, format: { with: %r{\A(#|/|https?://|mailto:)}, message: 'must start with #, /, http(s):// or mailto:' }, if: -> { kind == 'footer_link' }
  before_create { self.position = (self.class.where(kind: kind).maximum(:position) || -1) + 1 }
  scope :of, ->(k) { where(kind: k).order(:position, :id) }

  def move(dir)
    sibs = self.class.of(kind).to_a
    i = sibs.index(self)
    j = dir == 'up' ? i - 1 : i + 1
    return if j.negative? || j >= sibs.size
    sibs.insert(j, sibs.delete_at(i))
    sibs.each_with_index { |s, n| s.update_column(:position, n) }
  end
end
