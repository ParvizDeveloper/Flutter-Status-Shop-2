import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../pages/product_page.dart';
import '../pages/catalog_page.dart';

final List<Map<String, dynamic>> allProducts = [
  // --- TEXTILE ---
  {
    'name': {'ru': 'Футболка Статус', 'uz': 'Status futbolkasi', 'en': 'Status T-shirt'},
    'price': 95000,
    'images': ['assets/images/tshirt.png'],
    'description': {
      'ru': 'Футболка из плотного хлопка премиум-класса. Хорошо держит форму, приятная к телу, идеально подходит для термопереноса и повседневной носки.',
      'uz': 'Premium sifatli paxtadan tikilgan futbolka. Yaxshi shaklni saqlaydi, teriga yoqimli, termo bosma va kundalik kiyim uchun ideal.',
      'en': 'Premium-quality cotton T-shirt. Keeps its shape, soft on skin, ideal for heat transfer printing and everyday wear.'
    },
    'characteristics': {
      'material': {'ru':'Хлопок 100%','uz':'100% paxta','en':'100% cotton'},
      'weight': {'ru':'180 г/м²','uz':'180 g/m²','en':'180 g/m²'},
      'sizes': {'ru':'S–XXL','uz':'S–XXL','en':'S–XXL'},
      'suitable': {'ru':'Подходит для термопереноса','uz':'Termo bosma uchun mos','en':'Suitable for heat transfer'}
    },
    'type': 'clothes',
  },

  {
    'name': {'ru': 'Футболка Классик', 'uz': 'Classic futbolkasi', 'en': 'Classic T-shirt'},
    'price': 90000,
    'images': ['assets/images/tshirt.png'],
    'description': {
      'ru': 'Лёгкая классическая футболка с аккуратным швом. Удобна для повседневной носки и нанесения небольших принтов.',
      'uz': 'Yengil klassik futbolka, toza tikuv bilan. Kundalik kiyim va kichik printlar uchun qulay.',
      'en': 'Lightweight classic T-shirt with neat seams. Comfortable for daily wear and small prints.'
    },
    'characteristics': {
      'material': {'ru':'Хлопок 100%','uz':'100% paxta','en':'100% cotton'},
      'weight': {'ru':'150 г/м²','uz':'150 g/m²','en':'150 g/m²'},
      'sizes': {'ru':'S–XXL','uz':'S–XXL','en':'S–XXL'},
    },
    'type': 'clothes',
  },

  {
    'name': {'ru': 'Кепка', 'uz': 'Kepka', 'en': 'Cap'},
    'price': 80000,
    'images': ['assets/images/cap.png'],
    'description': {
      'ru': 'Универсальная кепка с регулируемой застёжкой. Подходит для нанесения вышивки и небольших термонаклеек.',
      'uz': 'Sozlanadigan qulflanishli universal kepka. Tikuv va kichik termo naqshlar uchun mos.',
      'en': 'Adjustable cap with a strap. Suitable for embroidery and small heat transfers.'
    },
    'characteristics': {
      'material': {'ru':'Хлопок','uz':'Paxta','en':'Cotton'},
      'adjustment': {'ru':'Регулируемая застёжка','uz':'Sozlanadigan qulflash','en':'Adjustable strap'},
    },
    'type': 'cap',
  },

  {
    'name': {'ru': 'Худи', 'uz': 'Hudi', 'en': 'Hoodie'},
    'price': 175000,
    'images': ['assets/images/hudi.png'],
    'description': {
      'ru': 'Тёплый худи с начёсом внутри, плотный материал и качественные швы. Отличный выбор для нанесения объемных принтов и флок-декора.',
      'uz': 'Ichida tukli issiq hudi, zich mato va sifatli tikuvlar. Hajmli printlar va flok dekor uchun yaxshi tanlov.',
      'en': 'Warm hoodie with brushed interior, dense fabric and quality seams. Great for bulky prints and flock decorations.'
    },
    'characteristics': {
      'material': {'ru':'Флис (начёс)','uz':'Fleece (tukli)','en':'Fleece (brushed)'},
      'sizes': {'ru':'M–XL','uz':'M–XL','en':'M–XL'},
      'uses': {'ru':'Подходит для флок, сублимации и термопереноса','uz':'Flok, sublimatsiya va termo bosma uchun mos','en':'Suitable for flock, sublimation and heat transfer'},
    },
    'type': 'oversize',
  },

  {
    'name': {'ru': 'Свитшот', 'uz': 'Svitsot', 'en': 'Sweatshirt'},
    'price': 160000,
    'images': ['assets/images/svitshot.png'],
    'description': {
      'ru': 'Классический свитшот из футера — удобен в носке и хорошо держит форму после стирок. Подходит для нанесения плотных принтов.',
      'uz': 'Futer materiale klassik svitsot — qulay va yuvishdan keyin shaklni saqlaydi. Qalin printlar uchun mos.',
      'en': 'Classic sweatshirt made of fleece — comfortable and retains shape after washes. Good for dense prints.'
    },
    'characteristics': {
      'material': {'ru':'Футер','uz':'Futer','en':'Fleece'},
      'sizes': {'ru':'S–XXL','uz':'S–XXL','en':'S–XXL'},
    },
    'type': 'clothes',
  },

  {
    'name': {'ru': 'ЭКО сумка', 'uz': 'EKO sumka', 'en': 'ECO Bag'},
    'price': 55000,
    'images': ['assets/images/eco_bag.png'],
    'description': {
      'ru': 'Экологичная сумка из спанбонда — лёгкая и прочная, удобна для нанесения логотипов и принтов.',
      'uz': 'Spanbonddan yasalgan ekologik sumka — yengil va mustahkam, logotip va printlar uchun qulay.',
      'en': 'Eco-friendly bag made of spunbond — lightweight and durable, easy for logos and prints.'
    },
    'characteristics': {
      'material': {'ru':'Спанбонд','uz':'Spanbond','en':'Spunbond'},
      'size': {'ru':'40×35 см','uz':'40×35 sm','en':'40×35 cm'},
    },
    'type': 'bag',
  },

  // --- VINYL ---
  {
    'name': {'ru': 'PU Flex', 'uz': 'PU Flex', 'en': 'PU Flex'},
    'price': 140000,
    'images': List.generate(41, (i) => 'assets/vinill/pu/pu_${i + 1}.png'),
    'description': {
      'ru': 'PU Flex — премиальная термотрансферная плёнка высокой эластичности и яркой передачи цвета. Подходит для спортивной и тонкой одежды.',
      'uz': 'PU Flex — yuqori elastiklik va yorqin rang beruvchi premium termo plyonka. Sport va yupqa kiyimlar uchun mos.',
      'en': 'PU Flex — premium heat transfer film with high elasticity and vivid color reproduction. Suitable for sportswear and lightweight fabrics.'
    },
    'characteristics': {
      'width': {'ru':'Ширина рулона: 50 см','uz':'Rolning eni: 50 sm','en':'Roll width: 50 cm'},
      'temp': {'ru':'Температура прессования: 150°C','uz':'Bosish harorati: 150°C','en':'Press temperature: 150°C'},
      'time': {'ru':'Время: 10 сек','uz':'Vaqt: 10 s','en':'Time: 10 sec'},
    },
    'type': 'vinil',
  },

  {
  'name': {'ru': 'PVC Flex', 'uz': 'PVC Flex', 'en': 'PVC Flex'},
  'price': 120000,

  // 🔥 Только твои реальные цвета
  'images': [
    'assets/vinill/pvc/pvc_1.png',
    'assets/vinill/pvc/pvc_2.png',
    'assets/vinill/pvc/pvc_3.png',
    'assets/vinill/pvc/pvc_9.png',
    'assets/vinill/pvc/pvc_11.png',
    'assets/vinill/pvc/pvc_15.png',
    'assets/vinill/pvc/pvc_17.png',
    'assets/vinill/pvc/pvc_28.png',
    'assets/vinill/pvc/pvc_31.png',
  ],

  'description': {
    'ru': 'Плотная PVC-плёнка для устойчивых к износу принтов. Подходит для рабочей и промо-одежды.',
    'uz': 'Kuchli PVC plyonka, aşınishga bardoshli printlar uchun. Ish kiyimi va promo kiyimlar uchun mos.',
    'en': 'Durable PVC film for wear-resistant prints. Good for workwear and promo apparel.'
  },

  'characteristics': {
    'width': {'ru':'50 см','uz':'50 sm','en':'50 cm'},
    'temp': {'ru':'155°C','uz':'155°C','en':'155°C'},
  },

  'type': 'vinil',
},


  {
    'name': {'ru': 'Flock', 'uz': 'Flock', 'en': 'Flock'},
    'price': 130000,
    'images': [
      'assets/vinill/flock/flock_black.png',
      'assets/vinill/flock/flock_cream.png',
      'assets/vinill/flock/flock_darkpink.png',
      'assets/vinill/flock/flock_green.png',
      'assets/vinill/flock/flock_indigo.png',
      'assets/vinill/flock/flock_red.png',
      'assets/vinill/flock/flock_sky.png',
      'assets/vinill/flock/flock_yellow.png',
    ],
    'description': {
      'ru': 'Бархатистый винил с мягкой текстурой — придаёт изделиям приятный тактильный эффект.',
      'uz': 'Yumshoq teksturali barxat vinil — buyumlarga yoqimli teginish beradi.',
      'en': 'Velvety vinyl with soft texture — gives garments a pleasant tactile feel.'
    },
    'characteristics': {
      'width': {'ru':'50 см','uz':'50 sm','en':'50 cm'},
      'temp': {'ru':'160°C','uz':'160°C','en':'160°C'},
    },
    'type': 'vinil',
  },

  {
  'name': {
    'ru': 'Stretch Foil',
    'uz': 'Stretch Foil',
    'en': 'Stretch Foil'
  },

  'price': 160000,

  /// все цвета Stretch Foil
  'images': [
    'assets/vinill/stretch/stretch_black.png',
    'assets/vinill/stretch/stretch_gold.png',
    'assets/vinill/stretch/stretch_rainbow.png',
    'assets/vinill/stretch/stretch_zebra.png',
  ],

  'description': {
    'ru': 'Металлизированная плёнка с хорошей тянущейся способностью — подходит для эффектных надписей и декоративных элементов.',
    'uz': 'Ajoyib cho‘ziladigan metall plyonka — dekorativ yozuvlar uchun mos.',
    'en': 'Metallic film with good stretchability — ideal for eye-catching lettering and decorations.'
  },

  'characteristics': {
    'width': {
      'ru': '50 см',
      'uz': '50 sm',
      'en': '50 cm'
    },
    'temp': {
      'ru': '145°C',
      'uz': '145°C',
      'en': '145°C'
    },
  },

  'type': 'vinil',
},

  {
    'name': {
      'ru': 'Metalic Flex',
      'uz': 'Metalic Flex',
      'en': 'Metalic Flex'
    },
    'price': 150000,

    /// 2 варианта цвета
    'images': [
      'assets/vinill/metalic/metallic_gold.png',
      'assets/vinill/metalic/metallic_silver.png',
    ],

    'description': {
      'ru': 'Глянцевая металлизированная плёнка для ярких, блестящих дизайнов.',
      'uz': 'Yorqin porloq metall plyonka — ko‘zni quvontiruvchi dizaynlar uchun.',
      'en': 'Glossy metallic film for bright, shiny designs.'
    },

    'characteristics': {
      'width': {
        'ru': '50 см',
        'uz': '50 sm',
        'en': '50 cm'
      },
      'temp': {
        'ru': '150°C',
        'uz': '150°C',
        'en': '150°C'
      },
    },

    'type': 'vinil',
    },

  {
    'name': {'ru': 'Reflective Flex', 'uz': 'Reflective Flex', 'en': 'Reflective Flex'},
    'price': 155000,
    'images': [
      'assets/vinill/reflective/reflective_black.png',
      'assets/vinill/reflective/reflective_chameleon.png'
    ],
    'description': {
      'ru': 'Светоотражающий винил для спортивной и рабочей одежды — повышает видимость в темное время суток.',
      'uz': 'Yorug‘lik aks ettiruvchi vinil — sport va ish kiyimi uchun xavfsizlikni oshiradi.',
      'en': 'Reflective vinyl for sports and workwear — enhances visibility at night.'
    },
    'characteristics': {
      'width': {'ru':'50 см','uz':'50 sm','en':'50 cm'},
      'temp': {'ru':'150°C','uz':'150°C','en':'150°C'},
    },
    'type': 'vinil',
  },

  // --- CUPS ---
  {
    'name': {'ru': 'Сублимационная кружка', 'uz': 'Sublimatsion krujka', 'en': 'Sublimation Mug'},
    'price': 25000,
    'images': ['assets/images/glass.png'],
    'description': {
      'ru': 'Белая керамическая кружка 330 мл, специально покрытая для сублимационной печати, устойчива к мытью и ярко передаёт цвета.',
      'uz': 'Sublimatsiya uchun qoplangan 330 ml keramika krujka. Yuvishga chidamli va ranglarni jonli beradi.',
      'en': 'White 330 ml ceramic mug pre-coated for sublimation printing, wash-resistant and vivid color reproduction.'
    },
    'characteristics': {
      'material': {'ru':'Керамика','uz':'Keramika','en':'Ceramic'},
      'volume': {'ru':'330 мл','uz':'330 ml','en':'330 ml'},
    },
    'type': 'cups',
  },

  {
    'name': {'ru': 'Термос для сублимации', 'uz': 'Termos', 'en': 'Sublimation Thermos'},
    'price': 70000,
    'images': ['assets/images/termos.png'],
    'description': {
      'ru': 'Металлический термос с покрытием под сублимацию, объём 500 мл. Долговечный и удобный для брендирования.',
      'uz': 'Sublimatsiya uchun qoplangan metall termos, hajmi 500 ml. Uzoq muddatli va brending uchun qulay.',
      'en': 'Metal thermos pre-coated for sublimation, 500 ml. Durable and great for branding.'
    },
    'characteristics': {
      'material': {'ru':'Нержавеющая сталь','uz':'Zanglamaydigan po‘lat','en':'Stainless steel'},
      'volume': {'ru':'500 мл','uz':'500 ml','en':'500 ml'},
    },
    'type': 'cups',
  },

  // --- EQUIPMENT ---
  {
    'name': {'ru': 'Плоттер Teneth 70см', 'uz': 'Plotter Teneth 70см', 'en': 'Teneth Plotter 70cm'},
    'price': 6800000,
    'images': ['assets/images/plotter.png'],
    'description': {
      'ru': 'Профессиональный режущий плоттер шириной до 70 см. Высокая точность, подходит для витринной и промышленной резки винила и термо материалов.',
      'uz': '70 sm gacha kesish qobiliyatiga ega professional plotter. Yuqori aniqlik, vinil va termo materiallar uchun mos.',
      'en': 'Professional cutting plotter up to 70 cm wide. High precision, suitable for vinyl and thermo materials.'
    },
    'characteristics': {
      'cut_width': {'ru':'Ширина резки: 70 см','uz':'Kesish eni: 70 sm','en':'Cut width: 70 cm'},
      'precision': {'ru':'Точность: 0.1 мм','uz':'Aniqlik: 0.1 mm','en':'Precision: 0.1 mm'},
    },
    'type': 'equipment',
  },

  {
    'name': {'ru': 'Cameo 5', 'uz': 'Cameo 5', 'en': 'Cameo 5'},
    'price': 5800000,
    'images': ['assets/images/cameo.png'],
    'description': {
      'ru': 'Компактный и удобный плоттер для малого и среднего бизнеса. Подходит для тонкой резки и сложных контуров.',
      'uz': 'Kichik va o‘rta biznes uchun kompakt plotter. Nozik kesish va murakkab konturlar uchun mos.',
      'en': 'Compact and handy plotter for small and medium businesses. Good for fine cuts and complex contours.'
    },
    'characteristics': {
      'cut_width': {'ru':'Ширина резки: 30 см','uz':'Kesish eni: 30 sm','en':'Cut width: 30 cm'},
    },
    'type': 'equipment',
  },

  {
    'name': {'ru': 'Термопресс 38×38', 'uz': 'Termopress 38×38', 'en': 'Heat Press 38×38'},
    'price': 3500000,
    'images': ['assets/images/termopress.png'],
    'description': {
      'ru': 'Надёжный настольный термопресс 38×38 см для переноса изображений на футболки и другие ткани. Быстрый и прост в использовании.',
      'uz': 'Kiyimlar va boshqa matolarga rasm ko‘chirish uchun 38×38 sm termopress. Tez va oson foydalanish.',
      'en': 'Reliable 38×38 cm tabletop heat press for transferring images onto T-shirts and fabrics. Fast and easy to use.'
    },
    'characteristics': {
      'plate': {'ru':'Размер пластины: 38×38 см','uz':'Plita o‘lchami: 38×38 sm','en':'Plate size: 38×38 cm'},
      'temp': {'ru':'Макс. температура: 200°C','uz':'Maks. harorat: 200°C','en':'Max temp: 200°C'},
    },
    'type': 'equipment',
  },

  {
    'name': {'ru': 'Термопресс 60×40', 'uz': 'Termopress 60×40', 'en': 'Heat Press 60×40'},
    'price': 4200000,
    'images': ['assets/images/termopress.png'],
    'description': {
      'ru': 'Большой производственный термопресс 60×40 см — подходит для массового производства и крупных изделий.',
      'uz': 'Keng miqyosli ishlab chiqarish uchun 60×40 sm termopress — katta buyumlar uchun mos.',
      'en': 'Large production heat press 60×40 cm — suitable for mass production and large items.'
    },
    'characteristics': {
      'plate': {'ru':'Размер пластины: 60×40 см','uz':'Plita o‘lchami: 60×40 sm','en':'Plate size: 60×40 cm'},
      'power': {'ru':'Мощность: 2.2 кВт','uz':'Quvvat: 2.2 kVt','en':'Power: 2.2 kW'},
    },
    'type': 'equipment',
  },

  {
    'name': {'ru': 'Термопресс для кепок', 'uz': 'Press kepkalarga', 'en': 'Cap Heat Press'},
    'price': 2200000,
    'images': ['assets/images/termo_cap.png'],
    'description': {
      'ru': 'Специализированный пресс для нанесения изображений на кепки — компактный и точный.',
      'uz': 'Kepkalarga rasm ko‘chirish uchun maxsus press — kompakt va aniq.',
      'en': 'Specialized press for caps — compact and precise.'
    },
    'characteristics': {
      'plate': {'ru':'Площадь: 15×8 см','uz':'Maydon: 15×8 sm','en':'Plate: 15×8 cm'},
    },
    'type': 'equipment',
  },

  {
    'name': {'ru': 'Термопресс для кружек', 'uz': 'Press krujkalar', 'en': 'Mug Heat Press'},
    'price': 1500000,
    'images': ['assets/images/termo_glass.png'],
    'description': {
      'ru': 'Пресс для кружек 330 мл — обеспечивает ровный и устойчивый перенос изображения.',
      'uz': '330 ml krujkalar uchun press — rasmni tekis va chidamli ko‘chiradi.',
      'en': '330 ml mug press — ensures even and durable image transfer.'
    },
    'characteristics': {
      'for_volume': {'ru':'Под кружки 330 мл','uz':'330 ml uchun','en':'For 330 ml mugs'},
    },
    'type': 'equipment',
  },

  {
    'name': {'ru': 'Мини-пресс', 'uz': 'Mini-press', 'en': 'Mini Press'},
    'price': 1200000,
    'images': ['assets/images/mini_press.png'],
    'description': {
      'ru': 'Компактный мини-пресс для небольших тиражей и мелкого бизнеса, экономит место и электричество.',
      'uz': 'Kichik biznes uchun kompakt mini-press, joy va elektrni tejaydi.',
      'en': 'Compact mini press for small runs and small businesses, saves space and energy.'
    },
    'characteristics': {
      'plate': {'ru':'Размер: небольшой','uz':'Hajmi: kichik','en':'Size: small'},
      'power': {'ru':'Мощность: 800 Вт','uz':'Quvvat: 800 Vt','en':'Power: 800 W'},
    },
    'type': 'equipment',
  },

  // --- DTF ---
  {
    'name': {'ru': 'DTF краска', 'uz': 'DTF bo‘yoq', 'en': 'DTF Ink'},
    'price': 250000,
    'images': ['assets/images/dtf_colors.png'],
    'description': {
      'ru': 'Пигментная DTF-краска CMYK + White для высококачественной печати на пленке перед переносом на ткань.',
      'uz': 'DTF CMYK + oq pigmentli siyoh — plyonkaga yuqori sifatli bosim uchun.',
      'en': 'Pigment DTF ink CMYK + White for high-quality printing on film prior to transfer.'
    },
    'characteristics': {
      'volume': {'ru':'Объём: 1 л','uz':'Hajm: 1 l','en':'Volume: 1 l'},
      'type': {'ru':'Пигментная','uz':'Pigmentli','en':'Pigment'},
    },
    'type': 'dtf',
  },

  {
    'name': {'ru': 'DTF плёнка', 'uz': 'DTF plyonka', 'en': 'DTF Film'},
    'price': 120000,
    'images': ['assets/images/dtf_plenka.png'],
    'description': {
      'ru': 'Матовая DTF-плёнка, рассчитанная на стабильную передачу красок и лёгкий отдел от основы при переносе.',
      'uz': 'Mat DTF plyonka — ranglarni barqaror uzatish va oson ajratish uchun.',
      'en': 'Matte DTF film designed for stable ink transfer and easy release during transfer.'
    },
    'characteristics': {
      'width': {'ru':'Ширина: 60 см','uz':'E: 60 sm','en':'Width: 60 cm'},
    },
    'type': 'dtf',
  },

  {
    'name': {'ru': 'DTF клей', 'uz': 'DTF yopishtiruvchi', 'en': 'DTF Powder/Adhesive'},
    'price': 85000,
    'images': ['assets/images/dtf_glue.png'],
    'description': {
      'ru': 'Порошковый клей для закрепления отпечатка при переносе DTF — обеспечивает хорошее сцепление с тканью.',
      'uz': 'DTF ko‘chirishda ishlatiladigan changli yopishtiruvchi — matoga yaxshi yopishadi.',
      'en': 'Powder adhesive for fixing DTF prints during transfer — provides good bonding to fabric.'
    },
    'characteristics': {
      'weight': {'ru':'Вес: 1 кг','uz':'Og‘irlik: 1 kg','en':'Weight: 1 kg'},
    },
    'type': 'dtf',
  },
];


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String formatPrice(num price) {
    final formatter = NumberFormat('#,###', 'ru');
    return '${formatter.format(price)} UZS';
  }

  String tr(BuildContext context, String ru, String uz, String en) {
    final lang = context.watch<LanguageProvider>().localeCode;
    if (lang == 'ru') return ru;
    if (lang == 'uz') return uz;
    return en;
  }

  String trName(BuildContext context, Map product) {
    final lang = context.watch<LanguageProvider>().localeCode;
    final name = product['name'];
    if (name is Map) return name[lang] ?? name['ru'];
    return name.toString();
  }

  String trCategoryText(BuildContext context, String ruCat) {
    return {
      "Текстиль": tr(context, "Текстиль", "Tekstil", "Textile"),
      "Термо винил": tr(context, "Термо винил", "Termo vinil", "Heat vinyl"),
      "DTF материалы":
          tr(context, "DTF материалы", "DTF materiallari", "DTF materials"),
      "Сублимационные кружки": tr(context, "Сублимационные кружки",
          "Sublimatsiya krujkalar", "Sublimation mugs"),
      "Оборудование":
          tr(context, "Оборудование", "Uskunalar", "Equipment"),
    }[ruCat] ?? ruCat;
  }

  @override
  Widget build(BuildContext context) {
    final tCategories = tr(context, "Категории", "Kategoriyalar", "Categories");
    final tPopular = tr(context, "Популярное", "Ommabop", "Popular");
    final tRecommended =
        tr(context, "Рекомендуем", "Tavsiya qilamiz", "Recommended");
    final tAbout = tr(context, "О нас", "Biz haqimizda", "About us");
    final tMore = tr(context, "Подробнее", "Batafsil", "More");

    const redColor = Color(0xFFE53935);

    final featured = allProducts.take(6).toList();
    final recommended = allProducts.skip(6).take(6).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ЛОГО
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 90,
                      ),
                    ),
                  ),

                  // ---- КАТЕГОРИИ ----
                  _sectionTitle(tCategories),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16),
                      children: [
                        _category(context, Icons.checkroom, 'Текстиль'),
                        _category(context, Icons.layers, 'Термо винил'),
                        _category(context, Icons.print, 'DTF материалы'),
                        _category(context, Icons.coffee, 'Сублимационные кружки'),
                        _category(context, Icons.precision_manufacturing, 'Оборудование'),
                      ],
                    ),
                  ),

                  // ---- БАННЕР ----
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 16 / 6.5,
                        child: Image.asset(
                          'assets/images/sale_banner.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // ---- ПОПУЛЯРНОЕ ----
                  _sectionTitle(tPopular),
                  SizedBox(
                    height: 285,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: featured.length,
                      itemBuilder: (c, i) =>
                          _productCard(context, featured[i], tMore),
                    ),
                  ),

                  // ---- РЕКОМЕНДУЕМ ----
                  _sectionTitle(tRecommended),
                  SizedBox(
                    height: 285,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recommended.length,
                      itemBuilder: (c, i) =>
                          _productCard(context, recommended[i], tMore),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ---- О НАС ----
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            tAbout,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Status Shop\n"
                            "г. Ташкент, Чиланзар 1-й квартал, 59\n"
                            "+998 90 176 01 04\n"
                            "Пн-Сб: 10:00–19:00",
                            style: TextStyle(fontSize: 14, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- ЗАГОЛОВОК ----
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ---- КАТЕГОРИЯ ----
  Widget _category(BuildContext context, IconData icon, String ruCat) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CatalogPage(preselectedCategory: ruCat),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(icon, color: const Color(0xFFE53935), size: 30),
            ),
            const SizedBox(height: 6),
            Text(
              trCategoryText(context, ruCat),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------
  // 🔥 Исправленная карточка товара — БЕЗ overflow
  // ------------------------------------------------
  Widget _productCard(
      BuildContext context, Map<String, dynamic> product, String tMore) {
    const redColor = Color(0xFFE53935);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductPage(product: product)),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            /// Фото — адаптивное, без обрезания
            Container(
              height: 140,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                product['images'][0],
                fit: BoxFit.contain,
              ),
            ),

            /// Контент — в Expanded (overflow невозможен)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trName(context, product),
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${NumberFormat('#,###', 'ru').format(product['price'])} UZS",
                      style: const TextStyle(
                        color: redColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const Spacer(),

                    /// Кнопка "Подробнее"
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                          color: redColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tMore,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}