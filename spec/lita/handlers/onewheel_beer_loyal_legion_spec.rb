require 'spec_helper'

describe Lita::Handlers::OnewheelBeerLoyalLegion, lita_handler: true do
  it { is_expected.to route_command('loyallegion') }
  it { is_expected.to route_command('loyallegion 4') }
  it { is_expected.to route_command('loyallegion nitro') }
  it { is_expected.to route_command('loyallegion CASK') }
  it { is_expected.to route_command('loyallegion <$4') }
  it { is_expected.to route_command('loyallegion < $4') }
  it { is_expected.to route_command('loyallegion <=$4') }
  it { is_expected.to route_command('loyallegion <= $4') }
  it { is_expected.to route_command('loyallegion >4%') }
  it { is_expected.to route_command('loyallegion > 4%') }
  it { is_expected.to route_command('loyallegion >=4%') }
  it { is_expected.to route_command('loyallegion >= 4%') }
  it { is_expected.to route_command('loyallegionabvhigh') }
  it { is_expected.to route_command('loyallegionabvlow') }

  before do
    mock = File.open('spec/fixtures/loyallegion.html').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the loyallegion taps' do
    send_command 'loyallegion'
    expect(replies.last).to eq('taps: 1) Coldfire Spring IPA  2) Block 15 Sticky Hands Imp. IPA  3) Red Ox ISA  4) Coalition Space Fruit IPA  5) Ruse Translator IPA  7) Leikam Across The Universe IPA  9) Rogue Cold Brew IPA  10) Rogue 6 Hop IPA  11) Migration Straight Outta Portland IPA  12) Silver Moon Crazy Horse IIPA  15) Alameda Admiration IPA  16) Gigantic Ginormous IIPA  19) Coalition Droppin’ Science IIPA  20) Ordnance Double Recoil Double IPA  21) Old Town Summer Of ’74 Tangerine Ale  22) Hopworks Lager  23) Ex Novo Hoppy Pils  24) Ex Novo The Most Interesting Lager In The World  25) Full Sail Session Lager $3 Pint  26) Heater Allen Helles Lager With German Malt  27) Heater Allen Helles Lager Made With Oregon Malt  28) Rogue Anniversary Charlie Strong Ale  29) Barley Brown’s Pygmy Pale Ale  30) Rogue Fresh Roast Ale  31) Fort George Quick Wit  32) Oakshire Hot Cakes Breakfast Brown Ale  33) FERMENT Pale  34) Gigantic/Half Acre Grimalkin Anomorphotron Imp. Stout/IPA  36) Coldfire St. James Red  38) Agrarian Amber Is The Color Of Your Energy  39) Double Mountain Vaporizer Dry Hop Plae  40) Coalition King Kitty Red  41) Cascade Lakes 20″ Brown  42) Double Mountain The Divine 9th Anni. Barrel Aged Brown  43) Breakside Guava Red  44) Hopworks Mother Russia Imp. Stout  45) Baerlic Old Blood And Guts Barleywine  46) Three Creeks 10 Pine Chocolate Porter  48) LEGION OF DOOM! Collab. Fruit Stout  51) Hopworks Evelyn Radshine Imp IPA Radler  53) Rogue Good Chit Pilsner  55) Laurelwood Dos Excellente Mexican Style Lager  56) Gigantic KolschTastic  57) Rogue 4 Hop Session IPA  58) Thunder Island Galaxy Single Hop Pale  59) Coalition Serendipity Session IPA  60) Hi Wheel Cranberry Zozzle  63) Deschutes Nitro Cream Ale  64) Wild Ride Nut Crusher Peanut Porter Nitro  65) Migration Clem’s Cream Ale Nitro  66) Fat Heads Rocket Man Red Nitro  67) Ex Novo Nautical By Nature Oyster Stout Nitro  68) Hopworks Velvet ESB Nitro  69) Hopworks Rise Up Red Nitro  70) Alameda Black Bear Nitro Stout  73) Upright Saison  74) Breakside Bergamot Special Bitter  75) Hopworks Pink Drink Rasp. Belgian Tripel  77) Occidental Sticke Alt  78) Rogue Doppelbock  79) Occidental Maibock  80) Commons Myrtle  81) Cider Riot Never Give A Inch Blkberry Cider  82) Alameda Betty Bunny Ale With Fruit  83) Hi Wheel Lemon Ginger Citrus Wine  84) Wildcraft Barrel Aged Kiwi Cider  85) Ecliptic Callisto Black Currant Tripel  86) Rogue New Crustacean Barleywine/Trip IPA  87) Swift Dank Cider  88) Alameda A Is For Apricot Tart Ale  89) Anthem Apple Cider  90) Ground Breaker IPA #5  91) Alter Ego Sunny Cider  92) Coldfire Berliner Weiss  93) Hopworks Senior Saul T. Plum Gose  94) Stickmen Passionfruit Wheat  95) Culmination #PDXNOW Cali Common  96) Coalition Bose Mode Wild Ale Barrel Aged With Pears  97) Rogue YSB Cask')
  end

  it 'displays details for tap 4' do
    send_command 'loyallegion 4'
    expect(replies.last).to eq('Loyal Legion tap 4) Coalition Space Fruit IPA, 7.0%, 50.0 IBU, $6.00')
  end

  it 'doesn\'t explode on 1' do
    send_command 'loyallegion 1'
    expect(replies.count).to eq(1)
    expect(replies.last).to eq('Loyal Legion tap 1) Coldfire Spring IPA, 6.9%, 85.0 IBU, $6.00')
  end

  it 'gets nitro' do
    send_command 'loyallegion nitro'
    expect(replies.last).to eq('Loyal Legion tap 70) Alameda Black Bear Nitro Stout, 6.8%, 55.0 IBU, $6.00')
  end

  it 'searches for ipa' do
    send_command 'loyallegion ipa'
    expect(replies.last).to eq('Loyal Legion tap 90) Ground Breaker IPA #5, 5.6%, 60.0 IBU, $5.00')
  end

  it 'searches for abv >9%' do
    send_command 'loyallegion >9%'
    expect(replies.count).to eq(6)
    expect(replies[0]).to eq('Loyal Legion tap 20) Ordnance Double Recoil Double IPA, 10.5%, 80.0 IBU, $6.00')
  end

  it 'searches for abv > 9%' do
    send_command 'loyallegion > 9%'
    expect(replies.count).to eq(6)
    expect(replies[0]).to eq('Loyal Legion tap 20) Ordnance Double Recoil Double IPA, 10.5%, 80.0 IBU, $6.00')
  end

  it 'searches for abv >= 9%' do
    send_command 'loyallegion >= 9%'
    expect(replies.count).to eq(8)
    expect(replies[0]).to eq('Loyal Legion tap 20) Ordnance Double Recoil Double IPA, 10.5%, 80.0 IBU, $6.00')
  end

  it 'searches for abv <4.1%' do
    send_command 'loyallegion <4.1%'
    expect(replies.count).to eq(3)
    expect(replies[0]).to eq('Loyal Legion tap 51) Hopworks Evelyn Radshine Imp IPA Radler, 4.0%, 0.0 IBU, $6.00')
  end

  it 'searches for abv <= 4%' do
    send_command 'loyallegion <= 4%'
    expect(replies.count).to eq(3)
    expect(replies[0]).to eq('Loyal Legion tap 51) Hopworks Evelyn Radshine Imp IPA Radler, 4.0%, 0.0 IBU, $6.00')
  end

  it 'searches for prices >$5' do
    send_command 'loyallegion >$5'
    expect(replies.count).to eq(77)
    expect(replies[1]).to eq('Loyal Legion tap 2) Block 15 Sticky Hands Imp. IPA, 8.1%, 110.0 IBU, $6.00')
  end

  it 'searches for prices >=$6' do
    send_command 'loyallegion >=$6'
    expect(replies.count).to eq(77)
    expect(replies[0]).to eq('Loyal Legion tap 1) Coldfire Spring IPA, 6.9%, 85.0 IBU, $6.00')
  end

  it 'searches for prices > $5.99' do
    send_command 'loyallegion > $5.99'
    expect(replies.count).to eq(77)
    expect(replies[0]).to eq('Loyal Legion tap 1) Coldfire Spring IPA, 6.9%, 85.0 IBU, $6.00')
  end

  it 'searches for prices <$4.1' do
    send_command 'loyallegion <$4.1'
    expect(replies.count).to eq(1)
    expect(replies[0]).to eq('Loyal Legion tap 25) Full Sail Session Lager $3 Pint, 5.1%, 18.0 IBU, $3.00')
  end

  it 'searches for prices < $4.01' do
    send_command 'loyallegion < $4.01'
    expect(replies.count).to eq(1)
    expect(replies[0]).to eq('Loyal Legion tap 25) Full Sail Session Lager $3 Pint, 5.1%, 18.0 IBU, $3.00')
  end

  it 'searches for prices <= $4.00' do
    send_command 'loyallegion <= $4.00'
    expect(replies.count).to eq(1)
    expect(replies[0]).to eq('Loyal Legion tap 25) Full Sail Session Lager $3 Pint, 5.1%, 18.0 IBU, $3.00')
  end

  it 'runs a random beer through' do
    send_command 'loyallegion roulette'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('Loyal Legion tap')
  end

  it 'runs a random beer through' do
    send_command 'loyallegion random'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('Loyal Legion tap')
  end

  it 'searches with a space' do
    send_command 'loyallegion chocolate'
    expect(replies.last).to eq('Loyal Legion tap 46) Three Creeks 10 Pine Chocolate Porter, 8.4%, 26.0 IBU, $6.00')
  end

  it 'displays low abv' do
    send_command 'loyallegionabvhigh'
    expect(replies.last).to eq('Loyal Legion tap 45) Baerlic Old Blood And Guts Barleywine, 11.4%, 100.0 IBU, $6.00')
  end

  it 'displays high abv' do
    send_command 'loyallegionabvlow'
    expect(replies.last).to eq('Loyal Legion tap 92) Coldfire Berliner Weiss, 3.6%, 7.0 IBU, $6.00')
  end
end
