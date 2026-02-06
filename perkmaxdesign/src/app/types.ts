export interface Card {
  id: string;
  name: string;
  last4: string;
  bank: string;
  color: string;
  type: 'visa' | 'mastercard' | 'amex' | 'discover';
  annualFee?: number;
  activationDate?: string;
  isHighConfidence?: boolean;
  notes?: string;
}

export interface Recommendation {
  merchantName: string;
  card: Card;
  confidence: 'HIGH' | 'MED' | 'LOW';
  pointsMultiplier: number;
  reason: string;
  savedAmount: number;
}

export interface HistoryItem {
  id: string;
  merchantName: string;
  date: string;
  cardUsed: string;
  saved: number;
}
