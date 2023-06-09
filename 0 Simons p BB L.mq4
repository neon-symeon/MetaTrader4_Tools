//20181201  chmury i zawsze 50-55
//20181125  wprowadziłem poprawki i stylistyczne drobne zmiany, wykasowałem limit czasowy
//20160619  metoda ceny na sztywno. opisy ukrywają metodę ceny
//20150905  kolejne zmiany
//20150728  zmieniłem sposób przeliczęń wprowadzając prev_calculated i to jest b dobre
//+------------------------------------------------------------------+
#property copyright "(c)Szymon Marek 2018"
#property link      "www.SzymonMarek.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property description "Simon's L Bands"
#property description " "
#property description "L Bands określa standardowe ramy głównego trendu z użyciem chmury średnich zlokalizowanych w obrębie średniej SMA50. Dodatkowe ustawienia pozwalają dowolnie zmieniać docelowe parametry."
#property description " "
#property description "A Bollinger Band® is a set of lines plotted two standard deviations (positively and negatively) away from a simple moving average of the security's price. A Bollinger Band®, developed by famous technical trader John Bollinger."

//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property indicator_buffers 8
//+------------------------------------------------------------------+
double arr_bb_0[],arr_bb_1[];
double arr_bb_2[],arr_bb_3[];
double arr_bb_4[],arr_bb_5[];
double arr_bb_6[],arr_bb_7[];
//+------------------------------------------------------------------+
enum ENUMS_BB_SET
{
   set_BB_19_21,
   set_BB_26_34,
   set_BB_34_44,
   set_BB_45_55,
   set_BB_50_55,
   set_BB_89_111,
   set_BB_free
};
//+------------------------------------------------------------------+
enum ENUMS_BAND_TYPE
{
   band_cloud,
   band_hl
};
//+------------------------------------------------------------------+
//+ zmienne globalne
//+------------------------------------------------------------------+
long     lngG_ID        = ChartID();   //chart ID
string   strG_Symbol    = Symbol();
string   strG_NazwaIndi;
string   strG_BB      = "BBwow"; //nazwa Buttona
string   strG_TTNB    = "TTNB_BBL";  //pokazuje czas do nowego bara
int      intG_BB_val_1, intG_BB_val_2;
bool     blnG_CzyAlertUp = true;
bool     blnG_CzyAlertMd = true;
bool     blnG_CzyAlertDn = true;
ENUM_TIMEFRAMES   enmG_TF_1st = Period();
string            strG_TF_1st = translate_TF(enmG_TF_1st);
//
int intG_0_Val; int intG_0_IdxStyle;  ENUM_LINE_STYLE enmG_0_LineStyle; int intG_0_Width;  color clrG_0; ENUM_APPLIED_PRICE enmG_0_Price = PRICE_MEDIAN; int intG_0_Mode;
int intG_1_Val; int intG_1_IdxStyle;  ENUM_LINE_STYLE enmG_1_LineStyle; int intG_1_Width;  color clrG_1; ENUM_APPLIED_PRICE enmG_1_Price = PRICE_MEDIAN; int intG_1_Mode;
int intG_2_Val; int intG_2_IdxStyle;  ENUM_LINE_STYLE enmG_2_LineStyle; int intG_2_Width;  color clrG_2; ENUM_APPLIED_PRICE enmG_2_Price = PRICE_MEDIAN; int intG_2_Mode;
int intG_3_Val; int intG_3_IdxStyle;  ENUM_LINE_STYLE enmG_3_LineStyle; int intG_3_Width;  color clrG_3; ENUM_APPLIED_PRICE enmG_3_Price = PRICE_MEDIAN; int intG_3_Mode;
int intG_4_Val; int intG_4_IdxStyle;  ENUM_LINE_STYLE enmG_4_LineStyle; int intG_4_Width;  color clrG_4; ENUM_APPLIED_PRICE enmG_4_Price = PRICE_MEDIAN; int intG_4_Mode;
int intG_5_Val; int intG_5_IdxStyle;  ENUM_LINE_STYLE enmG_5_LineStyle; int intG_5_Width;  color clrG_5; ENUM_APPLIED_PRICE enmG_5_Price = PRICE_MEDIAN; int intG_5_Mode;
int intG_6_Val; int intG_6_IdxStyle;  ENUM_LINE_STYLE enmG_6_LineStyle; int intG_6_Width;  color clrG_6; ENUM_APPLIED_PRICE enmG_6_Price = PRICE_MEDIAN; int intG_6_Mode;
int intG_7_Val; int intG_7_IdxStyle;  ENUM_LINE_STYLE enmG_7_LineStyle; int intG_7_Width;  color clrG_7; ENUM_APPLIED_PRICE enmG_7_Price = PRICE_MEDIAN; int intG_7_Mode;

//+------------------------------------------------------------------+
//globalne zewnętrzne
//+------------------------------------------------------------------+
extern string           s0 = "--- Widoczność Oscylatora na Wykresie ---";//---
extern bool             blnE_Czy_Widoczny = true;
extern bool             blnE_Czy_Flash    = false;
extern int              intE_Flash_Time   = 10;
extern string           s1 = "--- Typ rysowanych wstęg ---";//---
extern ENUMS_BAND_TYPE  enmE_Band_Type = band_hl;
extern string           s2 = "--- Widoczność poszczególnych grup bazowych---";//---
extern bool             blnE_Czy_Gora     = true;
extern bool             blnE_Czy_Srodek   = true;
extern bool             blnE_Czy_Dol      = true;
extern bool             blnE_BoldLines    = false;
extern string           s3 = "--- TRYB HL---";//---
extern string           s4 = "--- Widoczność linii przy środku ---";//---extern bool             blnE_Czy_Srodek_HL = true;
extern bool             blnE_GLOWNA_WSTEGA_Czy_Srodek_M  = true;
extern bool             blnE_GLOWNA_WSTEGA_Czy_Srodek_HL = true;
extern bool             blnE_DRUGA_WSTEGA_Czy_Srodek_M   = true;
extern string           sX1 = "--- Kolor Linii w trybie hl ---";                       //---
extern color            clrE_color_base   = clrSilver;
extern color            clrE_color_extra  = clrGold;
extern string           s5 = "--- Parametry automatyczne ---";//---
extern ENUMS_BB_SET     enmE_Set = set_BB_free;
extern double           dblE_Odchylenie= 2.0;
extern string           s6 = "--- Parametry ręczne (gdy set_free) ---";//---
extern int              intE_Bazowy    = 55;
extern int              intE_Dodatkowy = 18;
extern string           s7 ="------------------------------";//---
extern bool             blnE_Czy_Alerts  = false; //Czy Alerty


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   intG_0_IdxStyle = DRAW_NONE;   
   intG_1_IdxStyle = DRAW_NONE;   
   intG_2_IdxStyle = DRAW_NONE;
   intG_3_IdxStyle = DRAW_NONE;
   intG_4_IdxStyle = DRAW_NONE;
   intG_5_IdxStyle = DRAW_NONE;
   intG_6_IdxStyle = DRAW_NONE;
   intG_7_IdxStyle = DRAW_NONE;

   if(intE_Bazowy == 40 && clrE_color_base == clrSilver) clrE_color_base = clrSalmon;
   if(intE_Bazowy == 40) clrE_color_base = clrLightSalmon;
   switch(enmE_Band_Type) 
   {
   case band_hl:
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;     intG_0_Width = 1;   clrG_0 = clrE_color_base;  enmG_0_Price = PRICE_MEDIAN;  intG_0_Mode = MODE_UPPER; SetIndexLabel(0,"Band U (M) "+IntegerToString(intE_Bazowy));
      if(blnE_GLOWNA_WSTEGA_Czy_Srodek_HL)
      {
         intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_DASHDOT;   intG_1_Width = 1;   clrG_1 = clrE_color_base;  enmG_1_Price = PRICE_HIGH;    intG_1_Mode = MODE_MAIN;  SetIndexLabel(1,"Band M (H) "+IntegerToString(intE_Bazowy));
         intG_3_IdxStyle = DRAW_LINE;  enmG_3_LineStyle = STYLE_DASHDOT;   intG_3_Width = 1;   clrG_3 = clrE_color_base;  enmG_3_Price = PRICE_LOW;     intG_3_Mode = MODE_MAIN;  SetIndexLabel(3,"Band L (L) "+IntegerToString(intE_Bazowy));
      }
      if(blnE_GLOWNA_WSTEGA_Czy_Srodek_M)
      {
         intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;     intG_2_Width = 1;   clrG_2 = clrE_color_base;  enmG_2_Price = PRICE_MEDIAN;  intG_2_Mode = MODE_MAIN;  SetIndexLabel(2,"Band M (M) "+IntegerToString(intE_Bazowy));
      }
      
      intG_4_IdxStyle = DRAW_LINE;  enmG_4_LineStyle = STYLE_SOLID;     intG_4_Width = 1;   clrG_4 = clrE_color_base;  enmG_4_Price = PRICE_MEDIAN;  intG_4_Mode = MODE_LOWER; SetIndexLabel(4,"Band L (M) "+IntegerToString(intE_Bazowy));
      if(intE_Dodatkowy>0)
      {
         intG_5_IdxStyle = DRAW_LINE;  enmG_5_LineStyle = STYLE_SOLID;  intG_5_Width = 1;   clrG_5 = clrE_color_extra;  enmG_5_Price = PRICE_MEDIAN;   intG_5_Mode = MODE_UPPER; SetIndexLabel(5,"Band H+ (M) "+IntegerToString(intE_Dodatkowy));
         intG_7_IdxStyle = DRAW_LINE;  enmG_7_LineStyle = STYLE_SOLID;  intG_7_Width = 1;   clrG_7 = clrE_color_extra;  enmG_7_Price = PRICE_MEDIAN;   intG_7_Mode = MODE_LOWER; SetIndexLabel(7,"Band L+ (M) "+IntegerToString(intE_Dodatkowy));         
         if(blnE_DRUGA_WSTEGA_Czy_Srodek_M)
         {
            intG_6_IdxStyle = DRAW_LINE;  enmG_6_LineStyle = STYLE_DOT;    intG_6_Width = 1;   clrG_6 = clrE_color_extra;  enmG_6_Price = PRICE_MEDIAN;   intG_6_Mode = MODE_MAIN;  SetIndexLabel(6,"Band M+ (M) "+IntegerToString(intE_Dodatkowy));
         }
      }
      break;
   case band_cloud:
      IndicatorShortName("BB_L Cloud type");
      intG_0_IdxStyle = DRAW_HISTOGRAM;   enmG_0_LineStyle = STYLE_SOLID;   intG_0_Width = 1;   clrG_0 = clrGray;       SetIndexEmptyValue(0,0); SetIndexLabel(0,"Band U (M) "+IntegerToString(intE_Bazowy));
      intG_1_IdxStyle = DRAW_HISTOGRAM;   enmG_1_LineStyle = STYLE_SOLID;   intG_1_Width = 1;   clrG_1 = clrSilver;     SetIndexEmptyValue(1,0); SetIndexLabel(0,"Band U (M) "+IntegerToString(intE_Dodatkowy));
      intG_2_IdxStyle = DRAW_HISTOGRAM;   enmG_2_LineStyle = STYLE_SOLID;   intG_2_Width = 3;   clrG_2 = clrGray;       SetIndexEmptyValue(2,0); SetIndexLabel(0,"Band M (M) "+IntegerToString(intE_Bazowy));
      intG_3_IdxStyle = DRAW_HISTOGRAM;   enmG_3_LineStyle = STYLE_SOLID;   intG_3_Width = 3;   clrG_3 = clrSilver;     SetIndexEmptyValue(3,0); SetIndexLabel(0,"Band M (M) "+IntegerToString(intE_Dodatkowy));
      intG_4_IdxStyle = DRAW_HISTOGRAM;   enmG_4_LineStyle = STYLE_SOLID;   intG_4_Width = 1;   clrG_4 = clrGray;       SetIndexEmptyValue(4,0); SetIndexLabel(0,"Band L (M) "+IntegerToString(intE_Bazowy));
      intG_5_IdxStyle = DRAW_HISTOGRAM;   enmG_5_LineStyle = STYLE_SOLID;   intG_5_Width = 1;   clrG_5 = clrSilver;     SetIndexEmptyValue(5,0); SetIndexLabel(0,"Band L (M) "+IntegerToString(intE_Dodatkowy));
      intG_6_IdxStyle = DRAW_LINE;        enmG_6_LineStyle = STYLE_SOLID;   intG_6_Width = 2;   clrG_6 = clrSlateGray;  SetIndexEmptyValue(6,0); 
      intG_7_IdxStyle = DRAW_LINE;        enmG_7_LineStyle = STYLE_SOLID;   intG_7_Width = 2;   clrG_7 = clrSlateGray;  SetIndexEmptyValue(7,0); 
      break; 
   }
   //ustalam paramterty
   
   if(enmE_Band_Type == band_cloud)
   switch(enmE_Set)
   {
      case     set_BB_19_21:  intG_BB_val_1 = 21;  intG_BB_val_2 = 19; break;
      case     set_BB_26_34:  intG_BB_val_1 = 34;  intG_BB_val_2 = 26; break;
      case     set_BB_34_44:  intG_BB_val_1 = 44;  intG_BB_val_2 = 34; break;
      case     set_BB_45_55:  intG_BB_val_1 = 55;  intG_BB_val_2 = 45; break;
      case     set_BB_50_55:  intG_BB_val_1 = 55;  intG_BB_val_2 = 50; break;
      case     set_BB_89_111: intG_BB_val_1 = 111; intG_BB_val_2 = 89; break;
      case     set_BB_free:   intG_BB_val_1 = intE_Bazowy; intG_BB_val_2 = intE_Dodatkowy; break;
      default:                intG_BB_val_1 = 55;  intG_BB_val_2 = 50; break;
   }
   
   //nazwa
   if(enmE_Band_Type == band_cloud)   strG_NazwaIndi = "Simons BB("+IntegerToString(intG_BB_val_2)+":"+IntegerToString(intG_BB_val_1)+")."+DoubleToStr(dblE_Odchylenie,2);
   if(enmE_Band_Type == band_hl)      strG_NazwaIndi = "Simons BB_HL("+IntegerToString(intE_Bazowy)+")."+DoubleToStr(dblE_Odchylenie,2); 
   if(blnE_Czy_Alerts) strG_NazwaIndi = strG_NazwaIndi + " ALERTS";
   string strL_W = " Off";   
   if (blnE_Czy_Widoczny) strL_W = " On"; 
   IndicatorShortName(strG_NazwaIndi+strL_W);   
   
   //buforowanie
   SetIndexBuffer(0,arr_bb_0);
   SetIndexBuffer(1,arr_bb_1);
   SetIndexBuffer(2,arr_bb_2);
   SetIndexBuffer(3,arr_bb_3);
   SetIndexBuffer(4,arr_bb_4);
   SetIndexBuffer(5,arr_bb_5);
   SetIndexBuffer(6,arr_bb_6);
   SetIndexBuffer(7,arr_bb_7);
   //wyświetlanie buttona na wykresie
   string strL_Button_Txt = "L";
   if(intE_Bazowy!=50 || intE_Dodatkowy!=50) strL_Button_Txt = "L*"; 
   show_ButtonsOnScreen(strG_BB,strL_Button_Txt,intU_X+intU_Btn_width*2,intU_Y+intU_Btn_hight*2,intU_Btn_width,intU_Btn_hight);
   
   //wyświetlanie na wykresie
   if(blnE_Czy_Widoczny)
   {
      show_BB_On();
   }
   else
   {
      show_BB_Off();
      change_Button_State_Off(strG_BB);//guzik tez
   }

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void show_BB_On()
{

   switch(enmE_Band_Type) 
   {
   case band_hl:
      if(blnE_Czy_Gora)    SetIndexStyle(0,intG_0_IdxStyle,enmG_0_LineStyle,intG_0_Width,clrG_0); else SetIndexStyle(0,DRAW_NONE);
      if(blnE_Czy_Srodek && blnE_GLOWNA_WSTEGA_Czy_Srodek_HL)  SetIndexStyle(1,intG_1_IdxStyle,enmG_1_LineStyle,intG_1_Width,clrG_1); else SetIndexStyle(1,DRAW_NONE);
      if(blnE_Czy_Srodek && blnE_GLOWNA_WSTEGA_Czy_Srodek_M)   SetIndexStyle(2,intG_2_IdxStyle,enmG_2_LineStyle,intG_2_Width,clrG_2); else SetIndexStyle(2,DRAW_NONE);
      if(blnE_Czy_Srodek && blnE_GLOWNA_WSTEGA_Czy_Srodek_HL)  SetIndexStyle(3,intG_3_IdxStyle,enmG_3_LineStyle,intG_3_Width,clrG_3); else SetIndexStyle(3,DRAW_NONE);
      if(blnE_Czy_Dol)     SetIndexStyle(4,intG_4_IdxStyle,enmG_4_LineStyle,intG_4_Width,clrG_4); else SetIndexStyle(4,DRAW_NONE);
      if(intE_Dodatkowy>0) SetIndexStyle(5,intG_5_IdxStyle,enmG_5_LineStyle,intG_5_Width,clrG_5); else SetIndexStyle(5,DRAW_NONE);
      if(intE_Dodatkowy>0 && blnE_DRUGA_WSTEGA_Czy_Srodek_M)  SetIndexStyle(6,intG_6_IdxStyle,enmG_6_LineStyle,intG_6_Width,clrG_6); else SetIndexStyle(6,DRAW_NONE);
      if(intE_Dodatkowy>0) SetIndexStyle(7,intG_7_IdxStyle,enmG_7_LineStyle,intG_7_Width,clrG_7); else SetIndexStyle(7,DRAW_NONE);
      break;
   case band_cloud:
      if(blnE_Czy_Gora)    SetIndexStyle(0,intG_0_IdxStyle,enmG_0_LineStyle,intG_0_Width,clrG_0); else SetIndexStyle(0,DRAW_NONE);
      if(blnE_Czy_Gora)    SetIndexStyle(1,intG_1_IdxStyle,enmG_1_LineStyle,intG_1_Width,clrG_1); else SetIndexStyle(1,DRAW_NONE);
      if(blnE_Czy_Srodek)  SetIndexStyle(2,intG_2_IdxStyle,enmG_2_LineStyle,intG_2_Width,clrG_2); else SetIndexStyle(2,DRAW_NONE);
      if(blnE_Czy_Srodek)  SetIndexStyle(3,intG_3_IdxStyle,enmG_3_LineStyle,intG_3_Width,clrG_3); else SetIndexStyle(3,DRAW_NONE);
      if(blnE_Czy_Dol)     SetIndexStyle(4,intG_4_IdxStyle,enmG_4_LineStyle,intG_4_Width,clrG_4); else SetIndexStyle(4,DRAW_NONE);
      if(blnE_Czy_Dol)     SetIndexStyle(5,intG_5_IdxStyle,enmG_5_LineStyle,intG_5_Width,clrG_5); else SetIndexStyle(5,DRAW_NONE);
      if(blnE_BoldLines)   SetIndexStyle(6,intG_6_IdxStyle,enmG_6_LineStyle,intG_6_Width,clrG_6); else SetIndexStyle(6,DRAW_NONE);
      if(blnE_BoldLines)   SetIndexStyle(7,intG_7_IdxStyle,enmG_7_LineStyle,intG_7_Width,clrG_7); else SetIndexStyle(7,DRAW_NONE);    
      break;
   }
}
//+------------------------------------------------------------------+
void show_BB_Off()
{
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);
      SetIndexStyle(6,DRAW_NONE);
      SetIndexStyle(7,DRAW_NONE);      
}
//+------------------------------------------------------------------+
//| Custom indicator DeInit function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(ChartID(),strG_BB);
   ObjectDelete(ChartID(),strG_TTNB);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //if(ObjectFind(ChartID(),strG_BB)>-1) Alert("Znalazłem w On Calculate ",strG_BB);
   //else Alert("nie Znalazłem ",GetLastError());

   int intL_BTC;
         
   if (prev_calculated==0)                //dla pierwszego przelotu
   {
      intL_BTC=Bars-MathMax(intE_Bazowy,intE_Dodatkowy); 
   } 
   else if  (prev_calculated==rates_total)//przelicza tylko ostatni
   {
      intL_BTC=0; 
   }
   else
   {
      //control alerts
      if(blnE_Czy_Alerts)
      {
         blnG_CzyAlertUp = true;
         blnG_CzyAlertMd = true;
         blnG_CzyAlertDn = true;
      }
      //   
      intL_BTC=rates_total-prev_calculated+1;
   }
   if(enmE_Band_Type == band_cloud)
   {
      for(int i=0;i<=intL_BTC;i++)
      {
         arr_bb_0[i] = iBands(NULL,0,intG_BB_val_1,dblE_Odchylenie,0,PRICE_MEDIAN,MODE_UPPER,i);
         arr_bb_1[i] = iBands(NULL,0,intG_BB_val_2,dblE_Odchylenie,0,PRICE_MEDIAN,MODE_UPPER,i);
         
         arr_bb_2[i] = iBands(NULL,0,intG_BB_val_1,dblE_Odchylenie,0,PRICE_MEDIAN,MODE_MAIN,i);
         arr_bb_3[i] = iBands(NULL,0,intG_BB_val_2,dblE_Odchylenie,0,PRICE_MEDIAN,MODE_MAIN,i);
   
         arr_bb_4[i] = iBands(NULL,0,intG_BB_val_1,dblE_Odchylenie,0,PRICE_MEDIAN,MODE_LOWER,i);
         arr_bb_5[i] = iBands(NULL,0,intG_BB_val_2,dblE_Odchylenie,0,PRICE_MEDIAN,MODE_LOWER,i);
         
         if(blnE_BoldLines)
         {
            arr_bb_6[i] = iBands(NULL,0,intG_BB_val_2,dblE_Odchylenie,0,enmG_6_Price,intG_6_Mode,i);
            arr_bb_7[i] = iBands(NULL,0,intG_BB_val_2,dblE_Odchylenie,0,enmG_7_Price,intG_7_Mode,i);
         }
      }      
   }
   else if (enmE_Band_Type == band_hl)
   {
      for(int i=0;i<=intL_BTC;i++)
      {   
         arr_bb_0[i] = iBands(NULL,0,intE_Bazowy,dblE_Odchylenie,0,enmG_0_Price,intG_0_Mode,i);
         arr_bb_1[i] = iBands(NULL,0,intE_Bazowy,dblE_Odchylenie,0,enmG_1_Price,intG_1_Mode,i);
         arr_bb_2[i] = iBands(NULL,0,intE_Bazowy,dblE_Odchylenie,0,enmG_2_Price,intG_2_Mode,i);
         arr_bb_3[i] = iBands(NULL,0,intE_Bazowy,dblE_Odchylenie,0,enmG_3_Price,intG_3_Mode,i);
         arr_bb_4[i] = iBands(NULL,0,intE_Bazowy,dblE_Odchylenie,0,enmG_4_Price,intG_4_Mode,i);

         if(intE_Dodatkowy>0)
         {
            arr_bb_5[i] = iBands(NULL,0,intE_Dodatkowy,dblE_Odchylenie,0,enmG_5_Price,intG_5_Mode,i);
            arr_bb_6[i] = iBands(NULL,0,intE_Dodatkowy,dblE_Odchylenie,0,enmG_6_Price,intG_6_Mode,i);
            arr_bb_7[i] = iBands(NULL,0,intE_Dodatkowy,dblE_Odchylenie,0,enmG_7_Price,intG_7_Mode,i);
         }
     }
   }
   //
   manage_BB_Alerts(arr_bb_0,arr_bb_1,arr_bb_2,arr_bb_3,arr_bb_4,arr_bb_5,0);
   //--- return value of prev_calculated for next call
   
   //&& (Period() == PERIOD_M1 || Period() == PERIOD_M5 || Period() == PERIOD_M15)
   if(blnE_Czy_Flash && !blnE_Czy_Widoczny)
   {
      if       (Seconds()<intE_Flash_Time)  show_BB_On();
      else if  (ObjectGetInteger(ChartID(),strG_BB,OBJPROP_STATE)) show_BB_Off();
   }

   //EventSetTimer(1);
   if(Period() == PERIOD_M5)
   if(ObjectFind(ChartID(),strG_TTNB)<0)
      create_Label(ChartID(),strG_TTNB,0,65,10,CORNER_LEFT_LOWER,IntegerToString(60-Seconds()),"Arial Narrow",10,clrGold);
   else
   {
      //double dblL_a = MathAbs(Minute()/15+1)*15-Minute())-1;
      //if(dblL_a == 4
      ObjectSetString(ChartID(),strG_TTNB,OBJPROP_TEXT,"m15 za "+DoubleToStr((MathAbs(Minute()/15+1)*15-Minute())-1,0)+":"+IntegerToString(60-Seconds())+" sec."); 
   }
   return(rates_total);
} 
//+------------------------------------------------------------------+
void OnTimer()
{
}
//+------------------------------------------------------------------+
bool manage_BB_Alerts(  double      &head_BB_Up_1[], double &head_BB_Up_2[],
                        double      &head_BB_Md_1[], double &head_BB_Md_2[],
                        double      &head_BB_Dn_1[], double &head_BB_Dn_2[],
                        const int   head_i = 0)
                        
{
   if(!blnE_Czy_Alerts) return false;

   string strL_Info = Symbol() + " (" + strG_TF_1st + "): " + strG_NazwaIndi + " Says >> ";

   if(blnG_CzyAlertUp)
   if((High[head_i] >= head_BB_Up_1[head_i] && Low[head_i] < head_BB_Up_1[head_i]) || (High[head_i] >= head_BB_Up_2[head_i] && Low[head_i] < head_BB_Up_2[head_i]))
   {
      Alert(strL_Info," Górna banda");
      blnG_CzyAlertUp = false;
      return true;
   }
   if(blnG_CzyAlertMd)
   if((High[head_i] > head_BB_Md_1[head_i] && Low[head_i] < head_BB_Md_1[head_i]) || (High[head_i] >= head_BB_Md_2[head_i] && Low[head_i] < head_BB_Md_2[head_i]))
   {
      Alert(strL_Info," Mid banda");
      blnG_CzyAlertMd = false;
      return true;
   }
   if(blnG_CzyAlertDn)
   if((High[head_i] > head_BB_Dn_1[head_i] && Low[head_i] <= head_BB_Dn_1[head_i]) || (High[head_i] >= head_BB_Dn_2[head_i] && Low[head_i] <= head_BB_Dn_2[head_i]))
   {
      Alert(strL_Info," Dolna banda");
      blnG_CzyAlertDn = false;
      return true;
   }

   return false;
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if( id == CHARTEVENT_OBJECT_CLICK )
   {
      if(sparam==strG_BB)
      {         
         bool blnL_Button_BB_State = ObjectGetInteger(lngG_ID,strG_BB,OBJPROP_STATE);
         if(!blnL_Button_BB_State)
         {
            show_BB_On();
            change_Button_State_On(strG_BB);
         }
         else
         {
            show_BB_Off();
            change_Button_State_Off(strG_BB);
         }
      }
   }
}