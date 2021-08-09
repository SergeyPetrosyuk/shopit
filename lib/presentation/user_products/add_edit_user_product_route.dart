import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/products_provider.dart';

class AddEditUserProductRoute extends StatefulWidget {
  @override
  _AddEditUserProductRouteState createState() =>
      _AddEditUserProductRouteState();
}

class _AddEditUserProductRouteState extends State<AddEditUserProductRoute> {
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _title;
  String? _imageUrl;
  String? _description;
  String? _price;

  String? _updateProductId;

  bool _loading = false;

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  final String? Function(String?) _priceValidator = (value) {
    if (value == null || value.isEmpty) return 'Can\'t be blank';

    if (double.tryParse(value) == null) return 'Not valid value';

    if (double.parse(value) <= 0) return 'Should be greater than 9';

    return null;
  };

  final String? Function(String?) _blankValidator =
      (value) => (value == null || value.isEmpty) ? 'Can\'t be blank' : null;

  Future<void> _submitForm() async {
    final FormState? formState = _formKey.currentState;

    if (formState?.validate() == false) {
      return;
    }

    formState?.save();

    final productsProvider = context.read<ProductsProvider>();

    setState(() => _loading = true);

    try {
      await (_updateProductId == null
          ? productsProvider.addProduct(
              _title!,
              _description!,
              _imageUrl!,
              double.parse(
                _price!,
              ))
          : productsProvider.updateProduct(
              _updateProductId!,
              _title!,
              _description!,
              _imageUrl!,
              double.parse(_price!),
            ));
    } catch (error) {
      setState(() => _loading = false);
      await showDialog<Null>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Add product issue'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } finally {
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeDependencies() {
    final String? productId =
        ModalRoute.of(context)?.settings.arguments as String?;

    if (productId != null) {
      final product = context.read<ProductsProvider>().findById(productId);

      _title = product.title;
      _description = product.description;
      _imageUrlController.text = product.imageUrl;
      _price = product.price.toString();
      _updateProductId = product.id;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(onPressed: _submitForm, icon: Icon(Icons.save_rounded)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _title,
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        validator: _blankValidator,
                        onSaved: (value) => _title = value,
                      ),
                      TextFormField(
                        initialValue: _price,
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onSaved: (value) => _price = value,
                        validator: _priceValidator,
                      ),
                      TextFormField(
                        initialValue: _description,
                        decoration: InputDecoration(labelText: 'Description'),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        validator: _blankValidator,
                        onSaved: (value) => _description = value,
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 16, top: 16),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black54,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FittedBox(
                                child: Image.network(
                                  _imageUrlController.text,
                                  errorBuilder:
                                      (builderContext, object, trace) =>
                                          Icon(Icons.image),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: TextFormField(
                              controller: _imageUrlController,
                              decoration:
                                  InputDecoration(labelText: 'Image url'),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.url,
                              onChanged: (_) => setState(() {}),
                              onEditingComplete: () => setState(() {}),
                              onFieldSubmitted: (_) => _submitForm(),
                              onSaved: (value) => _imageUrl = value,
                              validator: _blankValidator,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
