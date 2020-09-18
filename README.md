# Flutter Dropdown_Below
-

A Flutter Dropdown library which is customize flutter dropdownbutton widget.


![](test1.gif)


## Options

| options | description |required|
|---|---|---
itemWidth |dropdown item's box width|X
itemTextstyle |dropdown item's text style|X
boxTextstyle |seletced box text style|X
boxPadding |seletced box inner padding|X
boxHeight | seletced box height|X
hint |text before you choose item|X
value |selected item|X
items | itemsList |O
onChange |change item function|O


## How to make it Work?
### Description for example.

### 1. datas


_testList's type is always be a list.

If you want to use map or other type, you can customize this package.

	  List _testList = [{'no': 1, 'keyword': 'blue'},{'no': 2, 'keyword': 'black'},{'no': 3, 'keyword': 'red'}];
	  List<DropdownMenuItem> _dropdownTestItems;
	  var _selectedTest;


### 2. initState & build items to correct type

If you want to customize item's child widget ex) Text -> Container, You can change any widget you want.

	  @override
	  void initState() {
	    _dropdownTestItems = buildDropdownTestItems(_testList);
	    super.initState();
	  }

	  List<DropdownMenuItem> buildDropdownTestItems(List _testList) {
	    List<DropdownMenuItem> items = List();
	    for (var i in _testList) {
	      items.add(
	        DropdownMenuItem(
	          value: i,
	          child: Text(i['keyword']),
	        ),
	      );
	    }
	    return items;
	  }

### 3. change function


	  onChangeDropdownTests(selectedTest) {
	    print(selectedTest);
	    setState(() {
	      _selectedTest = selectedTest;
	    });
	  }

### 4. UI

Dropdown Widget.

	    DropdownBelow(
	      itemWidth: 200,
	      itemTextstyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
	      boxTextstyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0XFFbbbbbb)),
	      boxPadding: EdgeInsets.fromLTRB(13, 12, 0, 12),
	      boxHeight: 45,
	      hint: Text('choose item'),
	      value: _selectedTest,
	      items: _dropdownTestItems,
	      onChanged: onChangeDropdownTests,
	    ),


<br/>


### 5. Question

1. IF you want to change size the parent box's size?
Than, why don't you wrap the DropdownBelow widget with Container.


2. IF you want to make itemBox dropdown when you enter the page?

Put this code to initState like this.

`
Timer(Duration(milliseconds: 200), () {
    CustomDropdownButtonState state = dropdownKey1.currentState;
    state.callTap();
});
`

And put key to Widget like this.

`
DropdownBelow(
  key: dropdownKey1,
  itemWidth: 200,
  itemTextstyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
  boxTextstyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0XFFbbbbbb)),
  boxPadding: EdgeInsets.fromLTRB(13, 12, 0, 12),
  boxHeight: 45,
  hint: Text('choose item'),
  value: _selectedTest,
  items: _dropdownTestItems,
  onChanged: onChangeDropdownTests,
),

Actually, dropdown widget is made by Navigation. So, it can work.

 	    `