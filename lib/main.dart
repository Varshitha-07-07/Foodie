
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const FoodieApp());
}

const Color foodieRed = Color(0xFFD7192D);
const Color foodieBackground = Color(0xFFF7F7F7);

class FoodieApp extends StatelessWidget {
  const FoodieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FOODIE',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: foodieBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: foodieRed),
      ),
      home: const SplashScreen(),
    );
  }
}

// ---------------- SPLASH SCREEN ----------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodieRed,
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // BIG SPLASH IMAGE
            SizedBox(
              width: 300,
              height: 300,
              child: Image.asset(
                'assets/images/burger.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.fastfood,
                  color: Colors.white,
                  size: 200,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'FOODIE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Delicious food, delivered to you',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ---------------- FOOD DATA ----------------

class FoodCategory {
  final String name;
  final String image;

  const FoodCategory(this.name, this.image);
}

const List<FoodCategory> categories = [
  FoodCategory('Burger', 'assets/images/burger.jpg'),
  FoodCategory('Drinks', 'assets/images/drink.jpg'),
  FoodCategory('Snacks', 'assets/images/mutton.jpg'),
  FoodCategory('Pizza', 'assets/images/prawn pizza.jpg'),
  FoodCategory('Biryani', 'assets/images/chickenbiryani.jpg'),
  FoodCategory('Chicken', 'assets/images/chicken.jpg'),
  FoodCategory('Mojito', 'assets/images/mojito.jpg'),
  FoodCategory('Cakes', 'assets/images/cake1.jpg'),
];

class Restaurant {
  final String name;
  final String description;
  final String image;
  final String discount;
  final double price;

  const Restaurant({
    required this.name,
    required this.description,
    required this.image,
    required this.discount,
    required this.price,
  });
}

const List<Restaurant> restaurants = [
  Restaurant(
    name: 'Royal Biryani House',
    description: 'Biryani • Indian',
    image: 'assets/images/chickenbiryani.jpg',
    discount: '50% OFF',
    price: 220,
  ),
  Restaurant(
    name: 'Pizza Corner',
    description: 'Pizza • Fast Food',
    image: 'assets/images/prawn pizza.jpg',
    discount: '20% OFF',
    price: 299,
  ),
  Restaurant(
    name: 'Burger Point',
    description: 'Burgers • Snacks',
    image: 'assets/images/burger.jpg',
    discount: '30% OFF',
    price: 149,
  ),
  Restaurant(
    name: 'Sweet Cake Studio',
    description: 'Desserts • Cakes',
    image: 'assets/images/cake2.jpg',
    discount: '15% OFF',
    price: 180,
  ),
];

// ---------------- HOME PAGE ----------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;
  String searchText = '';
  String selectedCategory = 'All';

  final TextEditingController searchController = TextEditingController();

  // Stores each restaurant and its quantity
  final Map<String, int> cart = {};

  int get cartCount => cart.values.fold(0, (sum, qty) => sum + qty);

  double get cartTotal {
    double total = 0;
    for (final restaurant in restaurants) {
      total += restaurant.price * (cart[restaurant.name] ?? 0);
    }
    return total;
  }

  void addToCart(Restaurant restaurant) {
    setState(() {
      cart[restaurant.name] = (cart[restaurant.name] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${restaurant.name} added to cart'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () => openTab(2),
        ),
      ),
    );
  }

  void increaseQuantity(Restaurant restaurant) {
    setState(() {
      cart[restaurant.name] = (cart[restaurant.name] ?? 0) + 1;
    });
  }

  void decreaseQuantity(Restaurant restaurant) {
    setState(() {
      final quantity = cart[restaurant.name] ?? 0;

      if (quantity <= 1) {
        cart.remove(restaurant.name);
      } else {
        cart[restaurant.name] = quantity - 1;
      }
    });
  }

  void removeFromCart(Restaurant restaurant) {
    setState(() {
      cart.remove(restaurant.name);
    });
  }

  void openTab(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedTab,
          children: [
            buildHomeContent(),
            const NearbyPage(),
            CartPage(
              cart: cart,
              total: cartTotal,
              onIncrease: increaseQuantity,
              onDecrease: decreaseQuantity,
              onRemove: removeFromCart,
              onCheckout: () {
                setState(() {
                  cart.clear();
                  selectedTab = 0;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demo order placed successfully!'),
                  ),
                );
              },
            ),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: openTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: foodieRed,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Nearby',
          ),
          BottomNavigationBarItem(
            icon: cartCount == 0
                ? const Icon(Icons.shopping_cart)
                : Badge(
                    label: Text('$cartCount'),
                    child: const Icon(Icons.shopping_cart),
                  ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildHomeContent() {
    final filteredRestaurants = restaurants.where((restaurant) {
      final query = searchText.toLowerCase();

      final matchesSearch =
          restaurant.name.toLowerCase().contains(query) ||
          restaurant.description.toLowerCase().contains(query);

      final category = selectedCategory.toLowerCase();

      final matchesCategory = selectedCategory == 'All' ||
          restaurant.name.toLowerCase().contains(category) ||
          restaurant.description.toLowerCase().contains(category);

      return matchesSearch && matchesCategory;
    }).toList();

    return CustomScrollView(
      slivers: [
        // RED HEADER

        SliverToBoxAdapter(
          child: Container(
            color: foodieRed,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 27,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deliver to',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Madhapur, Hyderabad',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => openTab(3),
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() => searchText = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search food or restaurants',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.mic_none,
                          color: foodieRed,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Voice search needs speech recognition setup.',
                              ),
                            ),
                          );
                        },
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // DEAL BANNERS

        SliverToBoxAdapter(
          child: SizedBox(
            height: 165,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              children: [
                buildDealCard(
                  "Today's Best Deals",
                  'Up to 75% off',
                  'assets/images/prawn pizza.jpg',
                  const [Color(0xFFFF6B20), Color(0xFFFFB34D)],
                ),
                const SizedBox(width: 12),
                buildDealCard(
                  'Weekly Deals',
                  'Save more today',
                  'assets/images/burger.jpg',
                  const [Color(0xFFE63E62), Color(0xFFFF8192)],
                ),
                const SizedBox(width: 12),
                buildDealCard(
                  'Tasty Offers',
                  'Delicious choices',
                  'assets/images/chickenbiryani.jpg',
                  const [Color(0xFF8E44AD), Color(0xFFCB72D9)],
                ),
              ],
            ),
          ),
        ),

        // CATEGORIES

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => selectedCategory = 'All');
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(color: foodieRed),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory =
                          selectedCategory == category.name
                              ? 'All'
                              : category.name;
                    });
                  },
                  child: SizedBox(
                    width: 82,
                    child: Column(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedCategory == category.name
                                  ? foodieRed
                                  : Colors.grey.shade300,
                              width:
                                  selectedCategory == category.name ? 3 : 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              category.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.fastfood),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // POPULAR RESTAURANTS TITLE

        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Restaurants',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchText = '';
                      selectedCategory = 'All';
                    });
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(color: foodieRed),
                  ),
                ),
              ],
            ),
          ),
        ),

        // FOOD CARDS WITH ADD TO CART

        if (filteredRestaurants.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text('No food items found.')),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 285,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return buildRestaurantCard(filteredRestaurants[index]);
                },
                childCount: filteredRestaurants.length,
              ),
            ),
          ),
      ],
    );
  }

  // DEAL CARD

  Widget buildDealCard(
    String title,
    String subtitle,
    String image,
    List<Color> colors,
  ) {
    return Container(
      width: 285,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 150,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.fastfood, size: 60),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.first,
                    colors.first.withValues(alpha: 0.9),
                    colors.first.withValues(alpha: 0.05),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FOOD CARD

  Widget buildRestaurantCard(Restaurant restaurant) {
    final quantity = cart[restaurant.name] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: const Color(0xFFF1F1F1),
                  child: Image.asset(
                    restaurant.image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: const BoxDecoration(
                      color: foodieRed,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(7),
                        bottomRight: Radius.circular(7),
                      ),
                    ),
                    child: Text(
                      restaurant.discount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 8, 9, 2),
            child: Text(
              restaurant.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Text(
              restaurant.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 5, 9, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '₹${restaurant.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: foodieRed,
                    ),
                  ),
                ),
                if (quantity == 0)
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () => addToCart(restaurant),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: foodieRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text(
                        'Add +',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: foodieRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          onPressed: () => decreaseQuantity(restaurant),
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          onPressed: () => increaseQuantity(restaurant),
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- CART PAGE ----------------

class CartPage extends StatelessWidget {
  final Map<String, int> cart;
  final double total;
  final Function(Restaurant) onIncrease;
  final Function(Restaurant) onDecrease;
  final Function(Restaurant) onRemove;
  final VoidCallback onCheckout;

  const CartPage({
    super.key,
    required this.cart,
    required this.total,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final cartRestaurants = restaurants
        .where((restaurant) => (cart[restaurant.name] ?? 0) > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: foodieRed,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: cartRestaurants.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Your cart is empty!',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Add your favourite food from Home.'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = cartRestaurants[index];
                      final quantity = cart[restaurant.name] ?? 0;

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  restaurant.image,
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(
                                    width: 85,
                                    height: 85,
                                    child: Icon(Icons.restaurant),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '₹${restaurant.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: foodieRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Row(
                                      children: [
                                        quantityButton(
                                          Icons.remove,
                                          () => onDecrease(restaurant),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            '$quantity',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        quantityButton(
                                          Icons.add,
                                          () => onIncrease(restaurant),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => onRemove(restaurant),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: foodieRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: foodieRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: onCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: foodieRed,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Place Order',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget quantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: foodieRed),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: foodieRed, size: 17),
      ),
    );
  }
}

// ---------------- NEARBY PAGE ----------------

class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, color: foodieRed, size: 65),
          SizedBox(height: 12),
          Text(
            'Nearby Restaurants',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Nearby restaurant listings can be added here.'),
        ],
      ),
    );
  }
}

// ---------------- PROFILE PAGE ----------------

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'FOODIE User';
  String email = 'user@gmail.com';

  void editProfile() {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: foodieRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  name = nameController.text.trim().isEmpty
                      ? 'FOODIE User'
                      : nameController.text.trim();

                  email = emailController.text.trim().isEmpty
                      ? 'user@gmail.com'
                      : emailController.text.trim();
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      emailController.dispose();
    });
  }

  void showMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title page coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodieBackground,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: foodieRed,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 15),
          const Center(
            child: CircleAvatar(
              radius: 52,
              backgroundColor: Color(0xFFF9DADD),
              child: Icon(
                Icons.person,
                size: 65,
                color: foodieRed,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ElevatedButton.icon(
              onPressed: editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: foodieRed,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          profileTile(
            Icons.shopping_bag_outlined,
            'My Orders',
            () => showMessage('My Orders'),
          ),
          profileTile(
            Icons.location_on_outlined,
            'Saved Addresses',
            () => showMessage('Saved Addresses'),
          ),
          profileTile(
            Icons.payment_outlined,
            'Payment Methods',
            () => showMessage('Payment Methods'),
          ),
          profileTile(
            Icons.notifications_outlined,
            'Notifications',
            () => showMessage('Notifications'),
          ),
          profileTile(
            Icons.settings_outlined,
            'Settings',
            () => showMessage('Settings'),
          ),
          profileTile(
            Icons.help_outline,
            'Help & Support',
            () => showMessage('Help & Support'),
          ),
        ],
      ),
    );
  }

  Widget profileTile(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: Icon(icon, color: foodieRed),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}