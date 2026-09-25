if ContentItem.none?
  seed = {
    'strip' => ['No contracts', 'Cancel anytime', 'Nationwide coverage', 'Keep your number'],
    'plan_item' => ['Unlimited talk and text', 'Unlimited high-speed data', 'Mobile hotspot included', 'Nationwide 5G / 4G LTE', 'Free number porting', '24/7 customer support']
  }
  seed.each { |k, list| list.each { |t| ContentItem.create!(kind: k, title: t) } }
  [['Unlimited everything', 'Talk, text, and data with no throttling. Stream and browse freely.'],
   ['Nationwide coverage', 'Runs on a major carrier network, so you stay connected across the country.'],
   ['One flat price', '$25 a month, all in. No surprise charges and no annual commitment.'],
   ['Keep your number', 'Bring the number you have now. We handle the transfer for you.'],
   ['Human support, 24/7', 'Reach real people by chat, email, or phone whenever you need help.'],
   ['Active in minutes', 'Order online, get your SIM in the mail, and activate it yourself.']].each { |t, b| ContentItem.create!(kind: 'feature', title: t, body: b) }
  [['Order your SIM', 'Sign up and we ship your SIM free. It arrives in 2–3 business days.'],
   ['Activate online', 'Insert the SIM and activate in minutes. Port your number or pick a new one.'],
   ['Start using it', "That's it. Enjoy unlimited service on a nationwide network."]].each { |t, b| ContentItem.create!(kind: 'step', title: t, body: b) }
  [['What network do you use?', 'We run on a major nationwide carrier network, with 5G/4G LTE coverage across the country.'],
   ['Can I keep my current number?', 'Yes. Number porting is free. Enter your current carrier details at signup and we handle the transfer, which usually finishes within 24 hours.'],
   ['Is there a contract?', 'No. Service is month-to-month, and you can cancel anytime without penalties or fees.'],
   ['Will my phone work?', "Most unlocked phones do. If you have an unlocked iPhone or Android from the last few years, you're set. The compatibility check at signup will confirm."],
   ['Are there hidden fees?', 'No. $25 a month includes taxes and fees. The only extra cost is a one-time $3 SIM card fee at signup.'],
   ['How do I get help?', 'Support is available 24/7 by chat, email, and phone, with real people on the other end.']].each { |t, b| ContentItem.create!(kind: 'faq', title: t, body: b) }
  [%w[Privacy #privacy], %w[Terms #terms], %w[Support #support], %w[About #about], %w[Contact #contact]].each { |t, b| ContentItem.create!(kind: 'footer_link', title: t, body: b) }
end
