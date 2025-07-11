class TestClass {
  int counter = 0;
  bool isActive = true;
  String name = "test";
  double value = 3.14;
  
  int calculate(int a, int b) {
    if (a > b && isActive) {
      counter++;
      return a + b * 2;
    } else if (a <= b || !isActive) {
      counter--;
      return (a - b ~/ 2);
    }
    return a % b;
  }
  
  void printResult() {
    print("Result: ${calculate(10, 5)}");
  }
  
  bool compare(int x, int y) {
    return x == y;
  }
  
  List<String> getItems() {
    List<String> items = ["a", "b", "c"];
    items.add("d");
    return items;
  }
}
