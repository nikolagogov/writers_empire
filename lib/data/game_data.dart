import '../models/location.dart';
import '../models/upgrade.dart';
import '../models/book.dart';

const List<Location> LOCS = [
  Location("📝 Child's Room", 1, 0),
  Location("🏚 Parents' Basement", 1, 1000000),
  Location("🚗 Garage", 1, 5000000),
  Location("🏠 Rented Attic", 1, 20000000),
  Location("🛋 Small Apartment", 1, 50000000),
  Location("🤝 Shared Office", 2, 50000),
  Location("🏢 Rented Office", 2, 200000000),
  Location("📣 Small Agency", 2, 800000000),
  Location("📚 Publishing House", 2, 3000000000),
  Location("🏙 City HQ", 2, 10000000000),
  Location("🗺 National Publisher", 3, 100000),
  Location("🌍 Continental Network", 3, 50000000000),
  Location("🌐 Global Empire", 3, 200000000000),
  Location("📡 Media Conglomerate", 3, 800000000000),
  Location("🏆 Literary Legend", 3, 3000000000000),
  Location("👁 Posthumous Fame", 4, 200000),
  Location("🎖 Nobel Archive", 4, 15000000000000),
  Location("🗿 Cultural Monument", 4, 80000000000000),
  Location("🔭 Galactic Library", 4, 400000000000000),
  Location("♾ Immortal Word", 4, 2000000000000000),
];

const List<Upgrade> UPGS = [
  Upgrade(id: "kb", name: "Keyboard", desc: "+2 words/click", baseCost: 100, val: 2, type: "click", max: 25),
  Upgrade(id: "mk", name: "Marketing", desc: "+8 words/click", baseCost: 600, val: 8, type: "click", max: 20),
  Upgrade(id: "cf", name: "Coffee", desc: "+0.5/sec", baseCost: 200, val: 0.5, type: "auto", max: 30),
  Upgrade(id: "ed", name: "Editor", desc: "+3/sec", baseCost: 1500, val: 3, type: "auto", max: 20),
  Upgrade(id: "gh", name: "Ghost Writer", desc: "+15/sec", baseCost: 10000, val: 15, type: "auto", max: 15),
  Upgrade(id: "ai", name: "AI Bot", desc: "+80/sec", baseCost: 70000, val: 80, type: "auto", max: 10),
];

const List<Book> BOOKS = [
  Book(id: "b1", title: "The First Draft", milestone: 10000, bonus: "click", val: 0.05, desc: "+5% click power"),
  Book(id: "b2", title: "Short Story", milestone: 100000, bonus: "auto", val: 0.05, desc: "+5% auto power"),
  Book(id: "b3", title: "Novella", milestone: 1000000, bonus: "click", val: 0.08, desc: "+8% click power"),
  Book(id: "b4", title: "First Novel", milestone: 10000000, bonus: "auto", val: 0.08, desc: "+8% auto power"),
  Book(id: "b5", title: "Bestseller", milestone: 100000000, bonus: "both", val: 0.10, desc: "+10% all power"),
  Book(id: "b6", title: "Award Winner", milestone: 1000000000, bonus: "both", val: 0.12, desc: "+12% all power"),
  Book(id: "b7", title: "Literary Classic", milestone: 1e13, bonus: "both", val: 0.15, desc: "+15% all power"),
  Book(id: "b8", title: "Immortal Opus", milestone: 1e16, bonus: "both", val: 0.20, desc: "+20% all power"),
];