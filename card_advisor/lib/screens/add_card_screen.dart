import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../app/theme.dart';
import '../models/credit_card.dart' as model;
import '../providers/card_provider.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = true;
  bool useBackgroundImage = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String cardNickname = '';
  int selectedColorIndex = 0;
  Map<model.RewardCategory, double> selectedRewards = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Add New Card'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CreditCardWidget(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                  obscureCardNumber: true,
                  obscureCardCvv: true,
                  isHolderNameVisible: true,
                  cardBgColor: AppTheme.cardGradients[selectedColorIndex],
                  glassmorphismConfig: useGlassMorphism
                      ? Glassmorphism(
                          blurX: 10.0,
                          blurY: 10.0,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              AppTheme.cardGradients[selectedColorIndex]
                                  .withValues(alpha: 0.8),
                              AppTheme
                                  .cardGradients[(selectedColorIndex + 1) %
                                      AppTheme.cardGradients.length]
                                  .withValues(alpha: 0.8),
                            ],
                          ),
                        )
                      : null,
                  onCreditCardWidgetChange: (CreditCardBrand brand) {},
                ),
                _buildColorSelector(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CreditCardForm(
                    formKey: formKey,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    onCreditCardModelChange: (CreditCardModel data) {
                      setState(() {
                        cardNumber = data.cardNumber;
                        expiryDate = data.expiryDate;
                        cardHolderName = data.cardHolderName;
                        cvvCode = data.cvvCode;
                        isCvvFocused = data.isCvvFocused;
                      });
                    },
                    obscureCvv: true,
                    obscureNumber: true,
                    inputConfiguration: const InputConfiguration(
                      cardNumberDecoration: InputDecoration(
                        labelText: 'Card Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                      ),
                      expiryDateDecoration: InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                      ),
                      cvvCodeDecoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: 'XXX',
                      ),
                      cardHolderDecoration: InputDecoration(
                        labelText: 'Card Holder',
                        hintText: 'Your Name',
                      ),
                    ),
                  ),
                ),
                _buildNicknameField(),
                _buildRewardCategorySelector(),
                _buildSaveButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Color',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppTheme.cardGradients.length,
              itemBuilder: (context, index) {
                final isSelected = selectedColorIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedColorIndex = index),
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardGradients[index],
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.cardGradients[index].withValues(
                            alpha: 0.5,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Card Nickname',
          hintText: 'e.g., Chase Sapphire, Amex Gold',
          prefixIcon: Icon(Icons.label_outline),
        ),
        onChanged: (value) => cardNickname = value,
      ),
    );
  }

  Widget _buildRewardCategorySelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reward Categories',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Set cashback percentages for each category',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          ...model.RewardCategory.values.map((category) {
            final categoryName =
                category.name[0].toUpperCase() + category.name.substring(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      categoryName,
                      style: const TextStyle(color: AppTheme.textDark),
                    ),
                  ),
                  Expanded(flex: 3, child: _buildRewardSlider(category)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRewardSlider(model.RewardCategory category) {
    final value = selectedRewards[category] ?? 1.0;
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryGold,
              inactiveTrackColor: AppTheme.surfaceColor,
              thumbColor: AppTheme.primaryGold,
              overlayColor: AppTheme.primaryGold.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: 0.5,
              max: 10,
              divisions: 19,
              onChanged: (newValue) {
                setState(() {
                  selectedRewards[category] = newValue;
                });
              },
            ),
          ),
        ),
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${value.toStringAsFixed(1)}%',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.primaryGold,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saveCard,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Save Card'),
        ),
      ),
    );
  }

  void _saveCard() {
    if (formKey.currentState?.validate() ?? false) {
      // Extract last 4 digits
      final cleanNumber = cardNumber.replaceAll(' ', '');
      final lastFour = cleanNumber.length >= 4
          ? cleanNumber.substring(cleanNumber.length - 4)
          : cleanNumber;

      // Determine card type
      model.CardType cardType = model.CardType.other;
      if (cleanNumber.startsWith('4')) {
        cardType = model.CardType.visa;
      } else if (cleanNumber.startsWith('5')) {
        cardType = model.CardType.mastercard;
      } else if (cleanNumber.startsWith('3')) {
        cardType = model.CardType.amex;
      } else if (cleanNumber.startsWith('6')) {
        cardType = model.CardType.discover;
      }

      // Fill in default rewards if not set
      final rewards = Map<model.RewardCategory, double>.from(selectedRewards);
      for (final category in model.RewardCategory.values) {
        rewards.putIfAbsent(category, () => 1.0);
      }

      final card = model.CreditCard(
        id: const Uuid().v4(),
        cardholderName: cardHolderName,
        lastFourDigits: lastFour,
        expiryDate: expiryDate,
        cardType: cardType,
        cardNickname: cardNickname.isNotEmpty
            ? cardNickname
            : '${cardType.name} Card',
        cardColor: selectedColorIndex.toString(),
        issuer: 'Custom',
        rewardRates: rewards,
      );

      context.read<CardProvider>().addCard(card);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${card.cardNickname} added successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }
}
