import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product';

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final TextEditingController _imageUrlController = TextEditingController();
  final _imageUrlFocus = FocusNode();
  final _formState = GlobalKey<FormState>();
  bool _isInit = false;
  bool _isLoading = false;

  Product _product = Product(
      id: '',
      title: '',
      price: 0.0,
      imageUrl: '',
      description: '',
      isFavourite: false);

  @override
  void dispose() {
    _imageUrlController.dispose();
    _imageUrlFocus.dispose();
    _imageUrlFocus.removeListener(_updateImageUrl);
    super.dispose();
  }

  @override
  void initState() {
    _imageUrlFocus.addListener((_updateImageUrl));
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocus.hasFocus) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      return;
    }
    final productId = ModalRoute.of(context)!.settings.arguments;

    if (productId == null) {
      _isInit = true;
      return;
    }

    _product =
        Provider.of<Products>(context, listen: false).getProduct(id: productId);
    _imageUrlController.text = _product.imageUrl;
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final Products products = Provider.of<Products>(context, listen: false);

    Future<void> saveForm() async {
      final isValid = _formState.currentState!.validate();
      if (!isValid) {
        return;
      }

      _formState.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      if (_product.id != '') {
        await products.updateProduct(_product.id, _product);
      } else {
        try {
          await products.addProduct(_product);
        } catch (error) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('An error occurred!'),
              content: const Text('Something went wrong.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formState,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value';
                        }

                        return null;
                      },
                      initialValue: _product.title,
                      onSaved: (value) => _product = Product(
                        title: value!,
                        price: _product.price,
                        id: _product.id,
                        description: _product.description,
                        imageUrl: _product.imageUrl,
                        isFavourite: _product.isFavourite,
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      initialValue:
                          _product.price == 0 ? '' : _product.price.toString(),
                      onSaved: (value) => _product = Product(
                          title: _product.title,
                          price: value!.isEmpty ? 0 : double.parse(value),
                          id: _product.id,
                          description: _product.description,
                          imageUrl: _product.imageUrl,
                          isFavourite: _product.isFavourite),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter a price.';
                        }

                        if (double.tryParse(val) == null) {
                          return 'Please enter a valid number.';
                        }

                        if (double.parse(val) <= 0) {
                          return 'Please enter a number greater than 0.';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      initialValue: _product.description,
                      onSaved: (value) => _product = Product(
                          title: _product.title,
                          price: _product.price,
                          id: _product.id,
                          description: value!,
                          imageUrl: _product.imageUrl,
                          isFavourite: _product.isFavourite),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter a description.';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1,
                                  color:
                                      Theme.of(context).colorScheme.outline)),
                          alignment: Alignment.center,
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Enter URL')
                              : SizedBox.expand(
                                  child: FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onEditingComplete: () => setState(() {}),
                            focusNode: _imageUrlFocus,
                            onFieldSubmitted: (_) {
                              saveForm();
                              Navigator.of(context).pop();
                            },
                            onSaved: (value) => _product = Product(
                                title: _product.title,
                                price: _product.price,
                                id: _product.id,
                                description: _product.description,
                                imageUrl: value!,
                                isFavourite: _product.isFavourite),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter an image URL.';
                              }

                              if (!val.startsWith('http') &&
                                  !val.startsWith('https')) {
                                return 'Please enter a valid URL.';
                              }

                              if (!val.endsWith('.png') &&
                                  !val.endsWith('.jpg') &&
                                  !val.endsWith('.jpeg')) {
                                return 'Please enter a URL that points to an image.';
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveForm();
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
