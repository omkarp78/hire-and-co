create extension if not exists pgcrypto;
create schema if not exists private;

create or replace function private.is_hire_admin()
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select lower(coalesce((select auth.jwt()->>'email'), '')) = 'omkarpatil0806@gmail.com'
$$;

create table if not exists public.products (
  id text primary key,
  name text not null,
  name_mr text,
  name_hi text,
  category text not null,
  product_type text not null,
  price numeric(10,2) not null check (price >= 0),
  compare_at numeric(10,2) not null default 0 check (compare_at >= 0),
  image text not null,
  media jsonb not null default '[]'::jsonb check (jsonb_typeof(media) = 'array'),
  description text not null default '',
  desc_mr text,
  desc_hi text,
  top_seller boolean not null default false,
  new_arrival boolean not null default false,
  active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.coupons (
  code text primary key check (code = upper(code)),
  discount_type text not null check (discount_type in ('percent','flat')),
  value numeric(10,2) not null check (value > 0),
  minimum numeric(10,2) not null default 0 check (minimum >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.home_settings (
  id smallint primary key default 1 check (id = 1),
  top_sellers_enabled boolean not null default true,
  top_sellers_title text not null default 'Top sellers this week.',
  top_seller_order text[] not null default '{}',
  new_arrivals_enabled boolean not null default true,
  new_arrivals_title text not null default 'New arrivals to meet.',
  new_arrival_order text[] not null default '{}',
  updated_at timestamptz not null default now()
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  product_id text not null references public.products(id) on delete cascade,
  customer_name text not null check (length(customer_name) between 1 and 80),
  rating smallint not null check (rating between 1 and 5),
  comment text not null check (length(comment) between 1 and 1200),
  published boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists reviews_product_created_idx on public.reviews(product_id, created_at desc);

create table if not exists public.orders (
  order_number text primary key,
  customer_name text not null,
  contact text not null default '',
  items_text text not null default '',
  total numeric(10,2) not null default 0 check (total >= 0),
  status text not null default 'Order received' check (status in ('Order received','Packed','Shipped','Out for delivery','Delivered','Cancelled')),
  created_at timestamptz not null default now()
);

create table if not exists public.order_tracking (
  order_number text primary key,
  status text not null default 'Order received' check (status in ('Order received','Packed','Shipped','Out for delivery','Delivered','Cancelled')),
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;
alter table public.coupons enable row level security;
alter table public.home_settings enable row level security;
alter table public.reviews enable row level security;
alter table public.orders enable row level security;
alter table public.order_tracking enable row level security;

drop policy if exists products_public_read on public.products;
create policy products_public_read on public.products for select to anon, authenticated using (active or private.is_hire_admin());
drop policy if exists products_admin_all on public.products;
create policy products_admin_all on public.products for all to authenticated using (private.is_hire_admin()) with check (private.is_hire_admin());

drop policy if exists coupons_public_read on public.coupons;
create policy coupons_public_read on public.coupons for select to anon, authenticated using (active);
drop policy if exists coupons_admin_all on public.coupons;
create policy coupons_admin_all on public.coupons for all to authenticated using (private.is_hire_admin()) with check (private.is_hire_admin());

drop policy if exists home_public_read on public.home_settings;
create policy home_public_read on public.home_settings for select to anon, authenticated using (true);
drop policy if exists home_admin_all on public.home_settings;
create policy home_admin_all on public.home_settings for all to authenticated using (private.is_hire_admin()) with check (private.is_hire_admin());

drop policy if exists reviews_public_read on public.reviews;
create policy reviews_public_read on public.reviews for select to anon, authenticated using (published or private.is_hire_admin());
drop policy if exists reviews_public_insert on public.reviews;
create policy reviews_public_insert on public.reviews for insert to anon, authenticated with check (published and length(trim(customer_name)) > 0 and length(trim(comment)) > 0);
drop policy if exists reviews_admin_all on public.reviews;
create policy reviews_admin_all on public.reviews for all to authenticated using (private.is_hire_admin()) with check (private.is_hire_admin());

drop policy if exists orders_admin_all on public.orders;
create policy orders_admin_all on public.orders for all to authenticated using (private.is_hire_admin()) with check (private.is_hire_admin());

drop policy if exists order_tracking_public_read on public.order_tracking;
create policy order_tracking_public_read on public.order_tracking for select to anon, authenticated using (true);
drop policy if exists order_tracking_admin_all on public.order_tracking;
create policy order_tracking_admin_all on public.order_tracking for all to authenticated using (private.is_hire_admin()) with check (private.is_hire_admin());

grant usage on schema public to anon, authenticated;
grant select on public.products, public.coupons, public.home_settings, public.reviews, public.order_tracking to anon, authenticated;
grant insert on public.reviews to anon, authenticated;
grant select, insert, update, delete on public.products, public.coupons, public.home_settings, public.reviews, public.orders, public.order_tracking to authenticated;
grant usage on schema private to anon, authenticated;
grant execute on function private.is_hire_admin() to anon, authenticated;

insert into public.products (id,name,name_mr,name_hi,category,product_type,price,compare_at,image,media,description,desc_mr,desc_hi,top_seller,new_arrival,sort_order)
select
  p.id,p.name,p."nameMr",p."nameHi",p.category,p.type,p.price,p."compareAt",p.image,p.media,p.description,p."descMr",p."descHi",p."topSeller",p."newArrival",j.ordinality::integer
from jsonb_array_elements('[{"id":"s1","name":"Ruby Jhumka Haar Set","nameMr":"रुबी झुमका हार सेट","nameHi":"रूबी झुमका हार सेट","category":"Jewellery Sets","type":"Traditional necklace & earring set","price":1899,"compareAt":0,"image":"media/ruby-jhumka-necklace-set.webp","media":[{"kind":"image","src":"media/pearl-jhumka-necklace-set.webp"},{"kind":"video","src":"media/ruby-jhumka-necklace-set.mp4"}],"description":"A gold-tone necklace with matching ruby jhumkas. The video shows the set from different angles.","descMr":"रुबी रंगाच्या खड्यांचे जुळणारे झुमके आणि सोनसळी हार. व्हिडिओमध्ये सेटचे वेगवेगळे कोन दिसतात.","descHi":"रूबी रंग के पत्थरों वाले मेल खाते झुमके और सुनहरे रंग का हार। वीडियो में सेट के अलग-अलग कोण दिखते हैं।","topSeller":true,"newArrival":true},{"id":"m1","name":"Mini Gold-Bead Mangalsutra","nameMr":"मिनी गोल्ड-बीड मंगळसूत्र","nameHi":"मिनी गोल्ड-बीड मंगलसूत्र","category":"Mangalsutra","type":"Gold plated daily use — short","price":750,"compareAt":0,"image":"media/daily-bead-mangalsutra-duo.webp","media":[{"kind":"image","src":"media/vijayalakshmi-combo-wide.webp"},{"kind":"video","src":"media/daily-bead-mangalsutra.mp4"}],"description":"Short daily-wear black-bead style. The uploaded offer image lists the mini mangalsutra at ₹750; confirm current availability on WhatsApp.","descMr":"दररोज वापरण्यासाठी छोट्या लांबीचे काळ्या मण्यांचे डिझाइन. अपलोड केलेल्या ऑफरच्या फोटोमध्ये मिनी मंगळसूत्राची किंमत ₹750 आहे; सध्याची उपलब्धता WhatsApp वर विचारा.","descHi":"रोज़ पहनने के लिए छोटे आकार का काले मोतियों वाला डिज़ाइन। अपलोड किए गए ऑफर चित्र में इसकी कीमत ₹750 दी है; उपलब्धता WhatsApp पर पूछें।","topSeller":true,"newArrival":false},{"id":"m2","name":"Long Gold-Bead Mangalsutra","nameMr":"लाँग गोल्ड-बीड मंगळसूत्र","nameHi":"लॉन्ग गोल्ड-बीड मंगलसूत्र","category":"Mangalsutra","type":"Gold plated daily use — long","price":1200,"compareAt":0,"image":"media/studio-long-bead-mangalsutras.webp","media":[{"kind":"image","src":"media/daily-bead-mangalsutra-duo.webp"},{"kind":"image","src":"media/vijayalakshmi-combo-portrait.webp"},{"kind":"video","src":"media/long-daily-mangalsutra.mp4"}],"description":"A long black-bead chain with gold-tone details and twin round pendants. The uploaded offer image lists it at ₹1,200; confirm current availability on WhatsApp.","descMr":"सोनसळी तपशील आणि दोन गोल लॉकेट असलेली लांब काळ्या मण्यांची साखळी. अपलोड केलेल्या ऑफरच्या फोटोमध्ये किंमत ₹1,200 आहे; सध्याची उपलब्धता WhatsApp वर विचारा.","descHi":"सुनहरे रंग के काम और दो गोल पेंडेंट वाली लंबी काले मोतियों की चेन। अपलोड किए गए ऑफर चित्र में कीमत ₹1,200 दी है; उपलब्धता WhatsApp पर पूछें।","topSeller":true,"newArrival":true},{"id":"m3","name":"Vijayalakshmi Festive Combo","nameMr":"विजयलक्ष्मी फेस्टिव्ह कॉम्बो","nameHi":"विजयलक्ष्मी फेस्टिव कॉम्बो","category":"Jewellery Sets","type":"Festive combo","price":1199,"compareAt":2550,"image":"media/vijayalakshmi-combo-portrait.webp","media":[{"kind":"image","src":"media/vijayalakshmi-combo-wide.webp"}],"description":"The uploaded offer image shows a long mangalsutra, mini mangalsutra and bangles set: listed total ₹2,550, offer ₹1,199. Please confirm that this offer is still active before ordering.","descMr":"अपलोड केलेल्या ऑफरच्या फोटोमध्ये लाँग मंगळसूत्र, मिनी मंगळसूत्र आणि बांगड्यांचा सेट दाखवला आहे: एकूण किंमत ₹2,550 आणि ऑफर किंमत ₹1,199. ऑर्डरपूर्वी ऑफर सुरू आहे का ते विचारा.","descHi":"अपलोड किए गए ऑफर चित्र में लॉन्ग मंगलसूत्र, मिनी मंगलसूत्र और चूड़ियों का सेट दिखाया गया है: कुल कीमत ₹2,550 और ऑफर कीमत ₹1,199। ऑर्डर से पहले ऑफर चालू है या नहीं, पूछें।","topSeller":true,"newArrival":false},{"id":"s2","name":"Pearl Knot Jhumka Set","nameMr":"पर्ल नॉट झुमका सेट","nameHi":"पर्ल नॉट झुमका सेट","category":"Jewellery Sets","type":"Traditional necklace & earring set","price":1599,"compareAt":0,"image":"media/pearl-jhumka-necklace-set.webp","media":[{"kind":"image","src":"media/ruby-jhumka-necklace-set.webp"}],"description":"A traditional gold-tone necklace and matching jhumkas with pearl and ruby-colour accents.","descMr":"मोती आणि रुबी रंगाच्या तपशीलांसह पारंपरिक सोनसळी हार व जुळणारे झुमके.","descHi":"मोती और रूबी रंग के काम वाला पारंपरिक सुनहरे रंग का हार और मेल खाते झुमके।","topSeller":false,"newArrival":true},{"id":"s3","name":"Two-Layer Ashtapailu Set","nameMr":"दोन पदरी अष्टपैलू सेट","nameHi":"दो परत वाला अष्टपैलू सेट","category":"Jewellery Sets","type":"Two-layer long necklace set","price":2199,"compareAt":0,"image":"media/two-layer-ashtapailu-poster.jpg","media":[{"kind":"video","src":"media/two-layer-ashtapailu-set.mp4"}],"description":"Two long gold-tone strands shown with matching jhumkas. The video text identifies it as a two-layer long Ashtapailu mala.","descMr":"जुळणाऱ्या झुमक्यांसह दाखवलेल्या सोनसळी रंगाच्या दोन लांब माळा. व्हिडिओवरील मजकूर याला दोन पदरी लांब अष्टपैलू माळ म्हणतो.","descHi":"मेल खाते झुमके और सुनहरे रंग की दो लंबी परतें। वीडियो में इसे दो परत वाली लंबी अष्टपैलू माला कहा गया है।","topSeller":false,"newArrival":true},{"id":"m4","name":"Emerald Rajwadi Mangalsutra Set","nameMr":"एमराल्ड राजवाडी मंगळसूत्र सेट","nameHi":"एमराल्ड राजवाड़ी मंगलसूत्र सेट","category":"Mangalsutra","type":"Rajwadi","price":2499,"compareAt":0,"image":"media/emerald-rajwadi-36.webp","media":[{"kind":"image","src":"media/emerald-floral-rajwadi-set.webp"},{"kind":"image","src":"media/emerald-floral-mangalsutra-set.webp"},{"kind":"image","src":"media/emerald-pendant-36-set.webp"}],"description":"A statement black-bead mangalsutra with emerald-colour stones and matching earrings. One uploaded photo marks the necklace as 36 inches.","descMr":"एमराल्ड रंगाचे खडे आणि जुळणारे झुमके असलेले उठावदार काळ्या मण्यांचे मंगळसूत्र. एका अपलोड केलेल्या फोटोमध्ये हाराची लांबी 36 इंच दिली आहे.","descHi":"एमराल्ड रंग के पत्थरों और मेल खाते झुमकों वाला आकर्षक काले मोतियों का मंगलसूत्र। अपलोड किए गए एक चित्र में हार की लंबाई 36 इंच दी है।","topSeller":true,"newArrival":false},{"id":"m5","name":"Green Kundan Rajwadi Set","nameMr":"हिरवा कुंदन राजवाडी सेट","nameHi":"हरा कुंदन राजवाड़ी सेट","category":"Mangalsutra","type":"Rajwadi","price":2699,"compareAt":0,"image":"media/green-kundan-rajwadi-set.webp","media":[{"kind":"image","src":"media/emerald-floral-mangalsutra-set.webp"},{"kind":"image","src":"media/emerald-pendant-36-set.webp"}],"description":"A richly detailed green-and-gold pendant set on a black-bead chain, with matching earrings.","descMr":"काळ्या मण्यांच्या साखळीवर हिरव्या-सोनसळी लॉकेटचे नक्षीकाम आणि जुळणारे झुमके.","descHi":"काले मोतियों की चेन पर हरे-सुनहरे पेंडेंट की बारीक कारीगरी और मेल खाते झुमके।","topSeller":false,"newArrival":true},{"id":"m6","name":"Floral Emerald Fusion Mangalsutra","nameMr":"फ्लोरल एमराल्ड फ्युजन मंगळसूत्र","nameHi":"फ्लोरल एमराल्ड फ्यूज़न मंगलसूत्र","category":"Mangalsutra","type":"Fusion mangalsutra","price":2299,"compareAt":0,"image":"media/emerald-floral-rajwadi-set.webp","media":[{"kind":"image","src":"media/emerald-rajwadi-36.webp"},{"kind":"image","src":"media/emerald-floral-mangalsutra-set.webp"}],"description":"A floral green-stone pendant brings a contemporary touch to the traditional black-bead chain.","descMr":"फुलांच्या आकाराचे हिरव्या खड्यांचे लॉकेट पारंपरिक काळ्या मण्यांच्या साखळीला आधुनिक लुक देते.","descHi":"फूलों के आकार वाला हरे पत्थरों का पेंडेंट पारंपरिक काले मोतियों की चेन को आधुनिक अंदाज़ देता है।","topSeller":false,"newArrival":true},{"id":"m7","name":"Green Kundan Long Mangalsutra Set","nameMr":"ग्रीन कुंदन लाँग मंगळसूत्र सेट","nameHi":"ग्रीन कुंदन लॉन्ग मंगलसूत्र सेट","category":"Mangalsutra","type":"Rajwadi","price":2799,"compareAt":0,"image":"media/emerald-floral-mangalsutra-set.webp","media":[{"kind":"image","src":"media/emerald-floral-rajwadi-set.webp"},{"kind":"image","src":"media/green-kundan-rajwadi-set.webp"}],"description":"A long, multi-strand black-bead design with green and clear-stone floral work and matching earrings.","descMr":"हिरव्या व पारदर्शक खड्यांची फुलांची नक्षी, अनेक काळ्या मण्यांच्या लांब पदरी आणि जुळणारे झुमके.","descHi":"हरे और पारदर्शी पत्थरों की फूलों वाली कारीगरी, काले मोतियों की कई लंबी लड़ियाँ और मेल खाते झुमके।","topSeller":false,"newArrival":false},{"id":"m8","name":"Emerald Pendant Rajwadi Set","nameMr":"एमराल्ड पेंडंट राजवाडी सेट","nameHi":"एमराल्ड पेंडेंट राजवाड़ी सेट","category":"Mangalsutra","type":"Rajwadi","price":2599,"compareAt":0,"image":"media/emerald-pendant-36-set.webp","media":[{"kind":"image","src":"media/emerald-rajwadi-36.webp"},{"kind":"image","src":"media/emerald-floral-mangalsutra-set.webp"}],"description":"A long black-bead set with an emerald-colour centre pendant and matching earrings.","descMr":"एमराल्ड रंगाचे मध्यवर्ती लॉकेट आणि जुळणारे झुमके असलेला लांब काळ्या मण्यांचा सेट.","descHi":"एमराल्ड रंग के बीच वाले पेंडेंट और मेल खाते झुमकों वाला लंबा काले मोतियों का सेट।","topSeller":false,"newArrival":false}]'::jsonb) with ordinality as j(value, ordinality)
cross join lateral jsonb_to_record(j.value) as p(id text,name text,"nameMr" text,"nameHi" text,category text,type text,price numeric,"compareAt" numeric,image text,media jsonb,description text,"descMr" text,"descHi" text,"topSeller" boolean,"newArrival" boolean)
on conflict (id) do nothing;

insert into public.coupons (code,discount_type,value,minimum,active) values ('GLOW10','percent',10,499,true) on conflict (code) do nothing;
insert into public.home_settings (id,top_sellers_enabled,top_sellers_title,top_seller_order,new_arrivals_enabled,new_arrivals_title,new_arrival_order)
values (1,true,'Top sellers this week.',array['m1','m2','m3','m4'],true,'New arrivals to meet.',array['s1','s2','s3','m5'])
on conflict (id) do nothing;

insert into storage.buckets (id,name,public) values ('product-images','product-images',true) on conflict (id) do update set public=true;
drop policy if exists product_images_public_read on storage.objects;
create policy product_images_public_read on storage.objects for select to anon, authenticated using (bucket_id = 'product-images');
drop policy if exists product_images_admin_insert on storage.objects;
create policy product_images_admin_insert on storage.objects for insert to authenticated with check (bucket_id = 'product-images' and private.is_hire_admin());
drop policy if exists product_images_admin_update on storage.objects;
create policy product_images_admin_update on storage.objects for update to authenticated using (bucket_id = 'product-images' and private.is_hire_admin()) with check (bucket_id = 'product-images' and private.is_hire_admin());
drop policy if exists product_images_admin_delete on storage.objects;
create policy product_images_admin_delete on storage.objects for delete to authenticated using (bucket_id = 'product-images' and private.is_hire_admin());
