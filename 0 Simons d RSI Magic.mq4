//+------------------------------------------------------------------+
//|                                                    RSI+ 6.10.mq4 |
//|                                     "(c) Szymon Marek 2015-2018" |
//|                                       http://www.SzymonMarek.com |
//+------------------------------------------------------------------+

#property copyright "(c) Szymon Marek 2015-2018"
#property link      "www.SzymonMarek.com"
#property version   "1.00"

#property strict
#property indicator_separate_window
#property description "Simon's RSI Magic to połączenie kilku pomiarów RSI: dwóch z tego timeframe'u i dwóch z wyższych timeframe'ów. Wybornie uzupełnia dynamiczne rozpoznanie trendu (wstęgi i Viper)i ułatwia chwytanie miejsc zwrotów."

//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 100
////+------------------------------------------------------------------+
//#property indicator_levelcolor clrGray
//#property indicator_levelstyle STYLE_DOT
//#property indicator_level1   20
//#property indicator_level2   30
//#property indicator_level3   40
//#property indicator_level4   60
//#property indicator_level5   70
//#property indicator_level6   80
//+------------------------------------------------------------------+
#property indicator_buffers 8
//+------------------------------------------------------------------+
//markery Trend Line RSI
#property indicator_color1 clrRoyalBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 5
//strzałki
#property indicator_color2 clrLime
#property indicator_color3 clrRed
//markery Zone RSI
#property indicator_color4 clrLime
#property indicator_width4 4
#property indicator_color5 clrRed
#property indicator_width5 4
#property indicator_color6 clrSilver
#property indicator_width6 1
#property indicator_color7 clrGold
#property indicator_width7 3
//markery classic RSI
#property indicator_color8 clrAqua
#property indicator_width7 3
//+------------------------------------------------------------------+
extern string  s0 = "*** Ustawienia RSI ***";                    //---
extern int              intE_RSI_TL_Val      = 14;             //bazowe ustawienie
extern int              intE_RSI_M1_Val      = 19;             //Tylko dla m1
extern int              intE_RSI_M5_Val      = 12;             //Tylko dla m5
extern int              intE_RSI_Zone_Val    = 30;             //Kropkowany Zone
extern double           dblE_RSI_Zone_Splash = 2.5;            //Tolerancja strfy 40 i 60
extern int              intE_RSI_HTF_Val     = 14;             //Ramki dla Higher Time Frame
extern int              intE_RSI_HHTF_Val    = 14;             //Ramki dla Higher & Higher Time Frame
extern string  s2 = "--- Które odczyty RSI wyswietlać ---";      //---
extern bool             blnE_Czy_T_RSI       = true;           //Trend Line RSI
extern bool             blnE_Czy_Z_RSI       = true;           //Zone RSI
extern string  s4 = "--- Strefy HTF ---";                        //---
extern bool             blnE_Czy_HTF         = true;           //Sterfy OB/OS z Higher Time Frame
extern ENUM_TIMEFRAMES  enmE_TF_2nd          = PERIOD_CURRENT; //Wyższy Interwał Czaowy (Current = Auto)
extern ENUM_TIMEFRAMES  enmE_TF_3rd          = PERIOD_CURRENT; //Jeszcze Wyższy Interwał Czaowy (Current = Auto)
extern string  s3 = "--- Czy wyświetlać strzałki ---";            //---
extern bool             blnE_Czy_Arrows       = true;          //Strzalki wyjścia z OB/OS
extern string  s5 = " Aktywacja i pozycja strzałek OB/OS ";       //---
extern int              intE_SignalLevel     = 80;             //Strefa sygnalna
extern int              intE_ArrowsPosition  = 85;             //Pozycja strzalek  
extern string  s6 = " Czy wyświetlać wartości RSI na HTF?";       //---
extern bool             blnE_Display_HTF_Val = true;
extern string  s7 = "--- Czy wyświetlać linie horyzontalne  ---"; //---
extern bool             blnE_Czy_H_Lines     = true;           //wszystkie linie poziome
extern string  s8 = "----------- Thick Line Level -----------";  //---
extern int              intE_LineLevel  = 60;
extern string  s9 = "----------- Czy Alerty -----------";         //---
extern bool             blnE_Alert_40_60     = false;          //Czy Alert Zone (40-60)
extern bool             blnE_Alert_20_80     = false;          //Czy Alert OBOS (20-80)

//+------------------------------------------------------------------+
string  s1 = "+++ Rodzaj ceny, just in case +++";
ENUM_APPLIED_PRICE   ext_METODA_CENY_tl  = PRICE_MEDIAN;
ENUM_APPLIED_PRICE   ext_METODA_CENY_zn  = PRICE_MEDIAN;
ENUM_APPLIED_PRICE   ext_METODA_CENY_htf = PRICE_MEDIAN;
//+------------------------------------------------------------------+
//tablice
double arr_RSI_TL[];
double arr_Arrow_Buy[];
double arr_Arrow_Sell[];
//zone rsi
double arr_RSI_Zone_Green[];  //byczy
double arr_RSI_Zone_Red[];    //niedźwiedzi
double arr_RSI_Zone_Silver[]; //neutralny
double arr_RSI_Zone_C[];      //C ZNACZY KRITICAL, STERFA KRYTYCZNA DLA TERNDU
double arr_RSI_M1[];
//do zaznaczania prostokątów z wyższych skal czasowych
double arr_RSI_HTF[];
double arr_RSI_HHTF[];
double arr_RSI_Zone[];        //liczony w ukryciu
double arr_RSI_9[];           //liczony w ukryciu
//+------------------------------------------------------------------+
//zmienne globalne;
//+------------------------------------------------------------------+
string   strG_NazwaIndi;;
int      intG_WinIdx;
int      intG_RSI_TTF_TC_Val; //w końcu jakie RSI liczyć 
//multi time frame
ENUM_TIMEFRAMES   enmG_TF_1st, enmG_TF_2nd, enmG_TF_3rd;
string            strG_TF_1st, strG_TF_2nd, strG_TF_3rd;
string            strG_RSI_TL, strG_RSI_Zone, strG_RSI_HTF,strG_RSI_HHTF;
//prostokąty
int intG_Rec_OS_No=0, intG_Rec_OB_No=0;
//middle line
string   strG_MidLine_Name = "MidLine", strG_40_Line = "_40_Line", strG_60_Line = "_60_Line";
string   strG_30_Line = "30_Line", strG_70_Line = "70_Line",strG_20_Line = "20_Line", strG_80_Line = "80_Line";
// odczyty z innych time frame
string strG_Readings_TF_1st   = "Readings TTF";
string strG_Readings_TF_2nd   = "Readings HTF 1";
string strG_Readings_TF_3rd   = "Readings HTF 2";
string strG_Shade_Readings    = "Shade";

bool blnG_Alert_TL_40_60 = true;
bool blnG_Alert_TL_20_80 = true;
bool blnG_Alert_ZN_40_60 = true;
bool blnG_Alert_ZN_20_80 = true;
bool blnG_Alert_eXtra = true;

//buttons
string strG_RSI_Arr_Up = "RSI_AU", strG_RSI_Arr_Dn = "RSI_AD";
string strG_RSI_ell_1 = "RSI_E1";
string strG_RSI_ell_2 = "RSI_E2";
string strG_RSI_ell_3 = "RSI_E3";
string strG_RSI_ell_4 = "RSI_E4";
string strG_RSI_ell_5 = "RSI_E5";


//waves
string col_fale_RomanBracekt[19]    = {"(i)","(ii)","(iii)","(iv)","(v)","(iv/a)","(v/b)","(i/a)","(ii/b)","(iii/c)","(a)","(b)","(c)","(d)","(e)","(w)","(x)","(y)","(z)"};
string col_fale_Roman[19]           = {"i","ii","iii","iv","v","i/a","ii/b","iii/c","iv/d","v/e","a","b","c","d","e","w","x","y","z"};
string col_fale_Small[22]           = {"1","2","3","4","5",">>5","6","7","1/a","2/b","3/c","4/d","5/e","a","b","c","d","e","w","x","y","z"};
string col_fale_Capital[17]         = {"1","2","3","4","5","1/A","2/B","3/C","A","B","C","D","E","W","X","Y","Z"};
string col_fale_ALT[19]             = {"alt1","alt2","alt3","alt4","alt5","RR","LL","BS","altA","altB","altC","altD","altE","altW","altX","altY","altZ","UP","DOWN"};

long lngG_ID = ChartID();

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //tylko do wizualizacji nie do dokładności obliczeń
   IndicatorDigits(1);
   //---
   IndicatorBuffers(12);
   //---nazwa oscylatora
   string strL_Price_Type = "?";
   if       (ext_METODA_CENY_tl == PRICE_MEDIAN)   strL_Price_Type = "Med Price";
   //ustawienia specyficzne
   if       (Period() == PERIOD_M1)                            intG_RSI_TTF_TC_Val = intE_RSI_M1_Val;
   else if  (Period() == PERIOD_M5)                            intG_RSI_TTF_TC_Val = intE_RSI_M5_Val;
   else                                                        intG_RSI_TTF_TC_Val = intE_RSI_TL_Val;
   
   //---ustawienia dla jawnych buforów
   SetIndexBuffer(0,arr_RSI_TL);          SetIndexStyle(0,DRAW_LINE);                           SetIndexLabel(0,"Trend RSI Line");
   SetIndexBuffer(1,arr_Arrow_Buy);       SetIndexStyle(1,DRAW_ARROW);  SetIndexArrow(1,233);   SetIndexLabel(1,"Bulls come back");    SetIndexEmptyValue(1,0.0);
   SetIndexBuffer(2,arr_Arrow_Sell);      SetIndexStyle(2,DRAW_ARROW);  SetIndexArrow(2,234);   SetIndexLabel(2,"Bears come back");    SetIndexEmptyValue(2,0.0);
   SetIndexBuffer(3,arr_RSI_Zone_Green);  SetIndexStyle(3,DRAW_ARROW);  SetIndexArrow(3,158);   SetIndexLabel(3,"Bullish Zone RSI");   SetIndexEmptyValue(3,0.0);
   SetIndexBuffer(4,arr_RSI_Zone_Red);    SetIndexStyle(4,DRAW_ARROW);  SetIndexArrow(4,158);   SetIndexLabel(4,"Bearish Zone RSI");   SetIndexEmptyValue(4,0.0);
   SetIndexBuffer(5,arr_RSI_Zone_Silver); SetIndexStyle(5,DRAW_ARROW);  SetIndexArrow(5,158);   SetIndexLabel(5,"Neutral Zone RSI");   SetIndexEmptyValue(5,0.0);
   SetIndexBuffer(6,arr_RSI_Zone_C);      SetIndexStyle(6,DRAW_ARROW);  SetIndexArrow(6,158);   SetIndexLabel(6,"Critical Zone RSI");  SetIndexEmptyValue(6,0.0);

   //---ustawienia dla buforów pomocniczych
   SetIndexBuffer(8,arr_RSI_Zone);
   SetIndexBuffer(9,arr_RSI_9);   
   SetIndexBuffer(10,arr_RSI_HTF);
   SetIndexBuffer(11,arr_RSI_HHTF);

   //---trend line rsi?
   if(!blnE_Czy_T_RSI)
   {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);            
   }
   //---arrows?
   if(!blnE_Czy_Arrows)
   {
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
   }
   //---zone rsi?
   if(!blnE_Czy_Z_RSI)
   {
      SetIndexStyle(3,DRAW_NONE);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);
      SetIndexStyle(6,DRAW_NONE);
   }
   //--- time frames
                                     enmG_TF_1st = Period();
   if(enmE_TF_2nd == PERIOD_CURRENT) enmG_TF_2nd = convert_TF_To_H_TF(enmG_TF_1st);    else enmG_TF_2nd = enmE_TF_2nd;
   if(enmE_TF_3rd == PERIOD_CURRENT) enmG_TF_3rd = convert_TF_To_HH_TF(enmG_TF_1st);   else enmG_TF_3rd = enmE_TF_3rd;
   
   strG_TF_1st = translate_TF(enmG_TF_1st);
   strG_TF_2nd = translate_TF(enmG_TF_2nd);
   strG_TF_3rd = translate_TF(enmG_TF_3rd);
   
   strG_RSI_TL    = IntegerToString(intG_RSI_TTF_TC_Val);
   strG_RSI_Zone  = IntegerToString(intE_RSI_Zone_Val);
   strG_RSI_HTF   = IntegerToString(intE_RSI_HTF_Val);
   strG_RSI_HHTF  = IntegerToString(intE_RSI_HHTF_Val);
   
   //---nazwa
   strG_NazwaIndi=StringConcatenate("Simon's Magic RSI");// by ",strL_Price_Type,"|",strG_TF_1st,".",strG_RSI_TL,"-",strG_RSI_Zone,";",strG_TF_2nd,"-",strG_TF_3rd,".",strG_RSI_HTF,"|");
   //if(blnE_Alert_20_80 || blnE_Alert_40_60)  strG_NazwaIndi = strG_NazwaIndi + " ALERTS";

   IndicatorShortName(strG_NazwaIndi);
   
   intG_WinIdx = WindowFind(strG_NazwaIndi);
   
   ////---środkowa linia
   //ObjectDelete(strG_20_Line);      create_H_Line(intG_WinIdx,strG_20_Line,20,clrGreen,STYLE_SOLID);       
   //ObjectDelete(strG_30_Line);      create_H_Line(intG_WinIdx,strG_30_Line,30,clrGreen,STYLE_DASH);
   //ObjectDelete(strG_40_Line);      create_H_Line(intG_WinIdx,strG_40_Line,40,clrGreen,STYLE_DASHDOT);          
   //ObjectDelete(strG_MidLine_Name); create_H_Line(intG_WinIdx,strG_MidLine_Name,50,clrSilver,STYLE_DOT);
   //ObjectDelete(strG_60_Line);      create_H_Line(intG_WinIdx,strG_60_Line,60,clrRed,  STYLE_DASHDOT);
   //ObjectDelete(strG_70_Line);      create_H_Line(intG_WinIdx,strG_70_Line,70,clrRed,  STYLE_DASH);       
   //ObjectDelete(strG_80_Line);      create_H_Line(intG_WinIdx,strG_80_Line,80,clrRed,  STYLE_SOLID);       

   //---środkowa linia
   ObjectDelete(strG_20_Line);
   ObjectDelete(strG_30_Line);
   ObjectDelete(strG_40_Line);
   ObjectDelete(strG_MidLine_Name);
   ObjectDelete(strG_60_Line);
   ObjectDelete(strG_70_Line);
   ObjectDelete(strG_80_Line);
   
   if(blnE_Czy_H_Lines)
   {
      create_H_Line(intG_WinIdx,strG_20_Line,20,      clrGreen,   STYLE_DASHDOT);       
      create_H_Line(intG_WinIdx,strG_30_Line,30,      clrGreen,   STYLE_DASH);
      create_H_Line(intG_WinIdx,strG_40_Line,40,      clrGreen,   STYLE_SOLID);          
      create_H_Line(intG_WinIdx,strG_MidLine_Name,50, clrSilver,  STYLE_DOT);
      create_H_Line(intG_WinIdx,strG_60_Line,60,      clrRed,     STYLE_SOLID);
      create_H_Line(intG_WinIdx,strG_70_Line,70,      clrRed,     STYLE_DASH);       
      create_H_Line(intG_WinIdx,strG_80_Line,80,      clrRed,     STYLE_DASHDOT);       
   }
   
   
   
   
   
   //info z innych TF-HTF
   show_Readings();
   
   //buttons to draw elliotts
   show_AllButtonsOnScreen();

   //---koniec
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(strG_MidLine_Name);
   ObjectDelete(strG_40_Line);
   ObjectDelete(strG_60_Line);
   ObjectDelete(strG_30_Line);
   ObjectDelete(strG_70_Line);
   ObjectDelete(strG_20_Line);
   ObjectDelete(strG_80_Line);
   ObjectDelete(strG_Readings_TF_1st);
   ObjectDelete(strG_Readings_TF_2nd);
   ObjectDelete(strG_Readings_TF_3rd);
   ObjectDelete(strG_Shade_Readings);
   //
   delete_Buttons();
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
//---
   //---zakres
   int intL_BTC_RSI = rates_total-prev_calculated+1;
   int intL_RSI_arrows = intL_BTC_RSI;  
   if       (prev_calculated==0)             {intL_BTC_RSI = Bars-intE_RSI_TL_Val-1;         intL_RSI_arrows = intL_BTC_RSI-1;}
   else if  (prev_calculated==rates_total)   {intL_BTC_RSI = 0;                              intL_RSI_arrows = intL_BTC_RSI;}
   else                                      {blnG_Alert_TL_20_80=true; blnG_Alert_TL_40_60=true; blnG_Alert_ZN_20_80=true; blnG_Alert_ZN_40_60=true; blnG_Alert_eXtra=true;}
   //
   for(int i=0;i<=intL_BTC_RSI;i++)
   {
      arr_RSI_TL[i]  = iRSI(NULL,0,intG_RSI_TTF_TC_Val,ext_METODA_CENY_tl,i);
      arr_RSI_Zone[i]= iRSI(NULL,0,intE_RSI_Zone_Val,ext_METODA_CENY_zn,i);
      arr_RSI_9[i]   = iRSI(NULL,0,9,PRICE_MEDIAN,i);
   }
   //---wyswietlanie dla zone rsi
   for(int i=0;i<=intL_BTC_RSI;i++)
   {
      arr_RSI_Zone_Green[i]   = 0;
      arr_RSI_Zone_Red[i]     = 0;
      arr_RSI_Zone_Silver[i]  = 0;
      arr_RSI_Zone_C[i]       = 0;
   
      double dblL_GreenZoneBeg= 60+dblE_RSI_Zone_Splash;
      double dblL_RedZoneBeg  = 40-dblE_RSI_Zone_Splash;
         
      if       (arr_RSI_Zone[i] > dblL_GreenZoneBeg)                                                     arr_RSI_Zone_Green[i]   = arr_RSI_Zone[i];
      else if  (arr_RSI_Zone[i] < dblL_RedZoneBeg)                                                       arr_RSI_Zone_Red[i]     = arr_RSI_Zone[i];
      else if  (    (arr_RSI_Zone[i]>=dblL_RedZoneBeg && arr_RSI_Zone[i]<40+dblE_RSI_Zone_Splash)
                 || (arr_RSI_Zone[i]> 60-dblE_RSI_Zone_Splash && arr_RSI_Zone[i]<=dblL_GreenZoneBeg))    arr_RSI_Zone_C[i]       = arr_RSI_Zone[i];
      else                                                                                               arr_RSI_Zone_Silver[i]  = arr_RSI_Zone[i];
   }
   //---wyświetlanie strzałek
   int intL_Sell = intE_SignalLevel;
   int intL_Buy  = 100-intE_SignalLevel;
   //
   for(int i=intL_RSI_arrows;i>=0;i--)
   {
      if (arr_RSI_TL[i+1] >= intL_Sell && arr_RSI_TL[i] < intL_Sell)
         arr_Arrow_Sell[i+1] = intE_ArrowsPosition;
      else
         arr_Arrow_Sell[i+1] = 0;
   }
   for(int i=intL_RSI_arrows;i>=0;i--)
   {
      if (arr_RSI_TL[i+1] <= intL_Buy && arr_RSI_TL[i] > intL_Buy)
         arr_Arrow_Buy[i+1] = 100-intE_ArrowsPosition;  
      else
         arr_Arrow_Buy[i+1] = 0;
   }
   //--- obliczenia higher time frame do ramek
   for(int i=0;i<=intL_BTC_RSI;i++)
   {
      int intL_TF_2nd   = iBarShift(NULL,enmG_TF_2nd,Time[i]);
      arr_RSI_HTF[i]    = iRSI(NULL,enmG_TF_2nd,intE_RSI_HTF_Val,ext_METODA_CENY_htf,intL_TF_2nd);
   }
   for(int i=0;i<=intL_BTC_RSI;i++)
   {
      int intL_TF_3rd   = iBarShift(NULL,enmG_TF_3rd,Time[i]);
      arr_RSI_HHTF[i]   = iRSI(NULL,enmG_TF_3rd,intE_RSI_HHTF_Val,ext_METODA_CENY_htf,intL_TF_3rd);
   }
   //---rysowanie prostokatow htf, kasowanie prostokatow htf
   if(blnE_Czy_HTF && prev_calculated!=rates_total) OBOS();
   if(!blnE_Czy_HTF && prev_calculated!=rates_total) //kasowanie obiektow ale tylko z nowym barem
   {
      int intL_ObjTotal = ObjectsTotal();
      for(int i=0;i<=intL_ObjTotal;i++)
      {
         string strL_NameOB = StringSubstr(ObjectName(ChartID(),i,intG_WinIdx,OBJ_RECTANGLE),0,3);
         string strL_NameOS = StringSubstr(ObjectName(ChartID(),i,intG_WinIdx,OBJ_RECTANGLE),0,3);
         if(strL_NameOB == "OB#" || strL_NameOB == "OS#")
         {
            ObjectsDeleteAll(intG_WinIdx, OBJ_RECTANGLE);           
            break;
         }
      }
   }
   //display the values of HTF radings 21/06/2018-29/06/2018
   manage_Readings();
   // manage alerts
   manage_Alerts();
   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
bool show_Readings()
{
   if(!blnE_Display_HTF_Val) return false;  //jak nie to nie
   //ustawienia zmiennych
   intG_WinIdx=WindowFind(strG_NazwaIndi);      //dla pewności 
   int intL_X = intU_X,  intL_Y = 20;               
   int intL_H = 20;                             //wysokość cienia
   if (enmG_TF_2nd!=enmG_TF_1st) intL_H = 33;   //wysokość cienia w trzech wariantach
   if (enmG_TF_3rd!=enmG_TF_2nd) intL_H = 45;  
   color clrL_Shade = ChartGetInteger(ChartID(),CHART_COLOR_BACKGROUND); //cień w kolorze tła
   //kasowanie poprzednich wynków
   delete_Readings();
   //tworzenie nowych
   create_RectLabel (ChartID(),strG_Shade_Readings,intG_WinIdx,intL_X,intL_Y,144,intL_H,clrL_Shade,1,CORNER_LEFT_UPPER);
   intL_Y = intL_Y + 4; //leciutki margines

                                 create_Label(ChartID(),strG_Readings_TF_1st,  intG_WinIdx,intL_X+6,intL_Y+13*1, CORNER_LEFT_UPPER,"Rea1","Arial",8);
   if (enmG_TF_2nd!=enmG_TF_1st) create_Label(ChartID(),strG_Readings_TF_2nd,  intG_WinIdx,intL_X+6,intL_Y+13*2, CORNER_LEFT_UPPER,"Rea2","Arial",8);
   if (enmG_TF_3rd!=enmG_TF_2nd) create_Label(ChartID(),strG_Readings_TF_3rd,  intG_WinIdx,intL_X+6,intL_Y+13*3, CORNER_LEFT_UPPER,"Rea3","Arial",8);
   //
   return true;
}
//+------------------------------------------------------------------+
bool delete_Readings()
{
   if(ObjectFind(ChartID(),strG_Shade_Readings) >-1)  ObjectDelete(ChartID(),strG_Shade_Readings);
   if(ObjectFind(ChartID(),strG_Readings_TF_1st) >-1)  ObjectDelete(ChartID(),strG_Readings_TF_1st);
   if(ObjectFind(ChartID(),strG_Readings_TF_2nd) >-1)  ObjectDelete(ChartID(),strG_Readings_TF_2nd);
   if(ObjectFind(ChartID(),strG_Readings_TF_3rd) >-1)  ObjectDelete(ChartID(),strG_Readings_TF_3rd);
   return true;
}
//+------------------------------------------------------------------+
bool manage_Readings()
{
   //abstrakt 20180825
   if(!blnE_Display_HTF_Val) return false;
   
   //początki opisów
   string strL_1TF, strL_2TF, strL_3TF;
   strL_1TF = strG_TF_1st+"("+strG_RSI_TL+")";
   strL_2TF = strG_TF_2nd+"("+strG_RSI_HTF+")";
   strL_3TF = strG_TF_3rd+"("+strG_RSI_HHTF+")";      
   //zmiana opisów
   if(ObjectFind(strG_Readings_TF_1st)>-1)
   {
      ObjectSetString(ChartID(),strG_Readings_TF_1st,OBJPROP_TEXT,strL_1TF+": "+DoubleToStr(arr_RSI_TL[0],1));
      color_Readings(strG_Readings_TF_1st,arr_RSI_TL[0]);
   }
   if(ObjectFind(strG_Readings_TF_2nd)>-1)
   {
      ObjectSetString(ChartID(),strG_Readings_TF_2nd,OBJPROP_TEXT,strL_2TF+": "+DoubleToStr(arr_RSI_HTF[0],1));
      color_Readings(strG_Readings_TF_2nd,arr_RSI_HTF[0]);
   }
   if(ObjectFind(strG_Readings_TF_3rd)>-1)
   {
      ObjectSetString(ChartID(),strG_Readings_TF_3rd,OBJPROP_TEXT,strL_3TF+": "+DoubleToStr(arr_RSI_HHTF[0],1));
      color_Readings(strG_Readings_TF_3rd,arr_RSI_HHTF[0]);
   }
   //długość cienia
   int intL_StringLen = calculate_Shadow_Len(strG_Readings_TF_1st,strG_Readings_TF_2nd,strG_Readings_TF_3rd);
   ObjectSetInteger(ChartID(),strG_Shade_Readings,OBJPROP_XSIZE,intL_StringLen);
   
   return true;
}
//+------------------------------------------------------------------+ 
void color_Readings(string head_Name,double head_RSI)
{
   //20180621
   long lngL_ChartID = ChartID();
   
   color clrL_Bull, clrL_Bear, clrL_Neutral, clrL_Critical, clrL_HotOB, clrL_ColdOS;
   color clrL_Shade = ChartGetInteger(ChartID(),CHART_COLOR_BACKGROUND);   
   if(clrL_Shade == clrWhite)
   {
      clrL_Bull      = clrGreen;
      clrL_Bear      = clrGreen;
      clrL_Neutral   = clrBlack;
      clrL_Critical  = clrDarkOrange;
      clrL_HotOB     = clrMagenta;
      clrL_ColdOS    = clrAqua;      
   }
   else
   {
      clrL_Bull      = clrLime;
      clrL_Bear      = clrRed;
      clrL_Neutral   = clrSilver;
      clrL_Critical  = clrGold;
      clrL_HotOB     = clrMagenta;
      clrL_ColdOS    = clrAqua;
   }

   if       (head_RSI >= 80)
   {
      ObjectSetInteger(ChartID(),head_Name,OBJPROP_COLOR,clrL_HotOB);
      //ObjectSetString(lngL_ChartID,head_Name,OBJPROP_FONT,"Arial Narrow");
   }
   else if  (head_RSI >  62.5)
   {
      ObjectSetInteger(ChartID(),head_Name,OBJPROP_COLOR,clrL_Bull);
      //ObjectSetString(lngL_ChartID,head_Name,OBJPROP_FONT,"Arial Black");   
   }
   else if  (head_RSI >  58 && head_RSI <= 62.5)
   {
      ObjectSetInteger(lngL_ChartID,head_Name,OBJPROP_COLOR,clrL_Critical);
      //ObjectSetString(lngL_ChartID,head_Name,OBJPROP_FONT,"Arial Black");   
   }
   else if  (head_RSI >= 42)
   {
      ObjectSetInteger(ChartID(),head_Name,OBJPROP_COLOR,clrL_Neutral);
      //ObjectSetString(lngL_ChartID,head_Name,OBJPROP_FONT,"Arial");
   }
   else if  (head_RSI >= 37.5 && head_RSI <  42)
   {
      ObjectSetInteger(ChartID(),head_Name,OBJPROP_COLOR,clrL_Critical);
      //ObjectSetString(lngL_ChartID,head_Name,OBJPROP_FONT,"Arial Black");   
   }
   else if  (head_RSI <  37.5 && head_RSI >  20)
   {
      ObjectSetInteger(ChartID(),head_Name,OBJPROP_COLOR,clrL_Bear);
      //ObjectSetString(lngL_ChartID,head_Name,OBJPROP_FONT,"Arial Black");   
   }
   else if  (head_RSI <= 20)
   {
      ObjectSetInteger(ChartID(),head_Name,OBJPROP_COLOR,clrL_ColdOS);
      //ObjectSetString(lngL_ChartID,head_Name,OBJPROP_FONT,"Arial Narrow");
   }
}
//+------------------------------------------------------------------+
//+                        Alert Management                          +
//+------------------------------------------------------------------+
bool manage_Alerts()
{
   if(!blnE_Alert_20_80 && ! blnE_Alert_40_60) return false;
   //
   string strL_Info = Symbol() + " (" + strG_TF_1st + "): " + strG_NazwaIndi;
   int intL_U_Alert = intE_LineLevel;//difoltowo 60
   int intL_L_Alert = 100- intE_LineLevel;//40
   //
   if(blnE_Alert_40_60 && blnG_Alert_TL_40_60)
   {
      //20180723/20190101 buy alert
      if (arr_RSI_TL[0]> arr_RSI_TL[1])
      if (arr_RSI_TL[1]>=intL_L_Alert-dblE_RSI_Zone_Splash && arr_RSI_TL[1]<=intL_L_Alert+dblE_RSI_Zone_Splash)
      if (arr_RSI_TL[2]>arr_RSI_TL[1])
      if (arr_RSI_TL[3]>arr_RSI_TL[1])
      {
         Alert(Symbol(),".",strG_TF_1st," Buy? RSI[1] = ",DoubleToStr(arr_RSI_TL[1],1),"vs. RSI[2]=",DoubleToStr(arr_RSI_TL[2],1));
         Alert(strL_Info," ZONE ",IntegerToString(intL_L_Alert)," ALERT fot Trend Line Says >> BUY");
         blnG_Alert_TL_40_60 = false;
      }
      //sell zone alert
      if (arr_RSI_TL[0]< arr_RSI_TL[1])      
      if (arr_RSI_TL[1]>=intL_U_Alert-dblE_RSI_Zone_Splash && arr_RSI_TL[1]<=intL_U_Alert+dblE_RSI_Zone_Splash)
      if (arr_RSI_TL[2]<arr_RSI_TL[1])
      if (arr_RSI_TL[3]<arr_RSI_TL[1])   
      {
         Alert(Symbol(),".",strG_TF_1st," Sell? RSI[1] = ",DoubleToStr(arr_RSI_TL[1],1),"vs. RSI[2]=",DoubleToStr(arr_RSI_TL[2],1));
         Alert(strL_Info," ZONE ",IntegerToString(intL_U_Alert)," ALERT fot Trend Line Says >> SELL");
         blnG_Alert_TL_40_60 = false;
      }
   }
   if(blnE_Alert_40_60 && blnG_Alert_ZN_40_60)
   {
      //20180723/20190101 buy alert
      if (arr_RSI_Zone[0]> arr_RSI_Zone[1])
      if (arr_RSI_Zone[1]>=40-dblE_RSI_Zone_Splash && arr_RSI_Zone[1]<=40+dblE_RSI_Zone_Splash)
      if (arr_RSI_Zone[2]>arr_RSI_Zone[1])
      if (arr_RSI_Zone[3]>arr_RSI_Zone[1])
      {
         Alert(Symbol(),".",strG_TF_1st," Buy? RSI[1] = ",DoubleToStr(arr_RSI_Zone[1],1),"vs. RSI[2]=",DoubleToStr(arr_RSI_Zone[2],1));
         Alert(strL_Info," ZONE 40 Alert for  Zone RSI Says >> BUY");
         blnG_Alert_ZN_40_60 = false;
      }
      //sell zone alert
      if (arr_RSI_Zone[0]< arr_RSI_Zone[1])      
      if (arr_RSI_Zone[1]>=60-dblE_RSI_Zone_Splash && arr_RSI_Zone[1]<=60+dblE_RSI_Zone_Splash)
      if (arr_RSI_Zone[2]<arr_RSI_Zone[1])
      if (arr_RSI_Zone[3]<arr_RSI_Zone[1])   
      {
         Alert(Symbol(),".",strG_TF_1st," Sell? RSI[1] = ",DoubleToStr(arr_RSI_Zone[1],1),"vs. RSI[2]=",DoubleToStr(arr_RSI_Zone[2],1));
         Alert(strL_Info," ZONE 60 Alert for  Zone RSI Says >> SELL");
         blnG_Alert_ZN_40_60 = false;
      }
   }   
   if(blnE_Alert_20_80 && blnG_Alert_TL_20_80)
   {
      if(arr_RSI_TL[1]>intE_SignalLevel && arr_RSI_TL[0]<intE_SignalLevel)
      {
         Alert(strL_Info," OBOS Alert for TL RSI Says >> SELL");
         blnG_Alert_TL_20_80 = false;
      }
      if(arr_RSI_TL[1]<(100-intE_SignalLevel) && arr_RSI_TL[0]>(100-intE_SignalLevel) )
      {
         Alert(strL_Info," OBOS Alert for TL RSI Says >> BUY");
         blnG_Alert_TL_20_80 = false;
      }
   }
      if(blnE_Alert_20_80 && blnG_Alert_ZN_20_80)
   {
      if(arr_RSI_Zone[1]>intE_SignalLevel && arr_RSI_Zone[0]<intE_SignalLevel)
      {
         Alert(strL_Info," OBOS Alert for ZONE RSI Says >> SELL");
         blnG_Alert_ZN_20_80 = false;
      }
      if(arr_RSI_Zone[1]<(100-intE_SignalLevel) && arr_RSI_Zone[0]>(100-intE_SignalLevel) )
      {
         Alert(strL_Info," OBOS Alert for ZONE RSI Says >> BUY");
         blnG_Alert_ZN_20_80 = false;
      }
   }
   if(blnG_Alert_eXtra)
   {
      //20180723/20190101 buy alert
      if (arr_RSI_Zone[0]> arr_RSI_Zone[1])
      if (arr_RSI_Zone[1]>=40-dblE_RSI_Zone_Splash && arr_RSI_Zone[1]<=40+dblE_RSI_Zone_Splash)
      if (arr_RSI_Zone[2]>arr_RSI_Zone[1])
      if (arr_RSI_Zone[3]>arr_RSI_Zone[1])
      if (arr_RSI_9[2]>100-intE_SignalLevel || arr_RSI_9[1]>100-intE_SignalLevel)
      if (arr_RSI_9[0]<100-intE_SignalLevel)
      
      {
         Alert(strL_Info," EXTRA (RSI(30)="+DoubleToStr(arr_RSI_Zone[0],1)+"; RSI(9)="+DoubleToStr(arr_RSI_9[0],1)+", ALERT Says >> BUY");
         blnG_Alert_eXtra = false;
      }
      //sell zone alert
      if (arr_RSI_Zone[0]< arr_RSI_Zone[1])      
      if (arr_RSI_Zone[1]>=60-dblE_RSI_Zone_Splash && arr_RSI_Zone[1]<=60+dblE_RSI_Zone_Splash)
      if (arr_RSI_Zone[2]<arr_RSI_Zone[1])
      if (arr_RSI_Zone[3]<arr_RSI_Zone[1])
      if (arr_RSI_9[2]>intE_SignalLevel || arr_RSI_9[1]>intE_SignalLevel)
      if (arr_RSI_9[0]<intE_SignalLevel)
       
      {
         Alert(strL_Info," EXTRA (RSI(30)="+DoubleToStr(arr_RSI_Zone[0],1)+"; RSI(9)="+DoubleToStr(arr_RSI_9[0],1)+", ALERT Says >> SELL");
         blnG_Alert_eXtra = false;
      }
   }
   return true;
}
//+------------------------------------------------------------------+
void OBOS()
//20150913 zacząłem a teraz (20150914) kontynuuję
//prostokąty OB/OS
{  
   intG_WinIdx=WindowFind(strG_NazwaIndi);
   ObjectsDeleteAll(intG_WinIdx,OBJ_RECTANGLE);

   //definicje przedziałów HHTF
   int   intL_Bull_Val_End_hhtf = 1;      //tylko tu i poniżej wpisuję wartość
   
   int   intL_Bull_Val_Beg_hhtf = 0; 
   int   intL_Bear_Val_Beg_hhtf = 100;
   int   intL_Bear_Val_End_hhtf = 100-intL_Bull_Val_End_hhtf; 
   
   //definicje przedziałów HTF
      int   intL_Bull_Val_End = 5;        //tu po raz ostatni wpisuję wartość
   
   int   intL_Bull_Val_Beg = intL_Bull_Val_End_hhtf+1;  
   int   intL_Bear_Val_Beg = 100-intL_Bull_Val_Beg;
   int   intL_Bear_Val_End = 100-intL_Bull_Val_End;


   int      intL_TimeEnd;
   int      intL_TimeBeg;

   int      intL_Sell_Sig = intE_SignalLevel;
   
   int      intL_Bull_TimeEnd;
   int      intL_Bull_TimeBeg;
   int      intL_Buy_Sig      = 100-intE_SignalLevel;   

   if(enmG_TF_2nd!=enmG_TF_1st)
   {      
   for (int i=Bars-20;i>=0;i--)//znajduję piewrszy punkt
   {
      //znajdowanie pierwszych parametrów
      if(arr_RSI_HTF[i]>=intL_Sell_Sig)
      {          
         intL_TimeBeg=i;
         for (int j=i-1;j>=0;j--)// znajduję drugi punkt
         if(arr_RSI_HTF[j]<intL_Sell_Sig || j == 0)
         {
            intL_TimeEnd=j;
            i=j;
            break;
         }
      // - - - rysowanie prostokąta
         if(intL_TimeBeg>intL_TimeEnd)
         {
            //licznik prostokątów OB
            intG_Rec_OB_No++;
            
            string strL_NoOf_OB_Bar=StringConcatenate(IntegerToString(intG_Rec_OB_No)," ",IntegerToString(MathRand()));
            string strL_RecName=StringConcatenate("OB#",strG_TF_2nd," ",strL_NoOf_OB_Bar);
            string strL_RecName2=StringConcatenate(strL_RecName,"|");
      
            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg=Time[intL_TimeBeg];
            datetime dttL_TimeEnd=Time[intL_TimeEnd];
      
            //wypełnienie
            ObjectCreate(ChartID(),strL_RecName2,OBJ_RECTANGLE,intG_WinIdx,dttL_TimeBeg,intL_Bear_Val_Beg,dttL_TimeEnd,intL_Bear_Val_End); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_COLOR,clrOrange);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_WIDTH,0);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTABLE,false); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTED,false);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_HIDDEN,true);                 
                          
            //ramka
            ObjectCreate(ChartID(),strL_RecName,OBJ_RECTANGLE,intG_WinIdx,dttL_TimeBeg,intL_Bear_Val_Beg,dttL_TimeEnd,intL_Bear_Val_End); 
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_COLOR,clrRed);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_WIDTH,3);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_BACK,false);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_SELECTABLE,false); 
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_SELECTED,false);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_HIDDEN,true);                 
          }
      }
   }
  
   for (int i=Bars-20;i>=0;i--)//znajduję piewrszy punkt
   {
      //znajdowanie pierwszych parametrów
      if(arr_RSI_HTF[i]<=intL_Buy_Sig)
      {        
         intL_Bull_TimeBeg=i;
         for (int j=i-1;j>=0;j--)// znajduję drugi punkt
         if(arr_RSI_HTF[j]>intL_Buy_Sig || j == 0)
         {
            intL_Bull_TimeEnd=j;
            i=j;
            break;
         }
         
      // - - - rysowanie prostokąta
         if(intL_Bull_TimeBeg>intL_Bull_TimeEnd)
         {  
            //licznik prostokątów OS
            intG_Rec_OS_No++;

            string strL_NoOf_OS_Bar=StringConcatenate(IntegerToString(intG_Rec_OS_No)," ",IntegerToString(MathRand()));
            string strL_RecName=StringConcatenate("OS#",strG_TF_2nd," ",strL_NoOf_OS_Bar);
            string strL_RecName2=StringConcatenate(strL_RecName,"|");   
      
            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg=Time[intL_Bull_TimeBeg];
            datetime dttL_TimeEnd=Time[intL_Bull_TimeEnd];
      
            //wypełnienie
            ObjectCreate(ChartID(),strL_RecName2,OBJ_RECTANGLE,intG_WinIdx,dttL_TimeBeg,intL_Bull_Val_Beg,dttL_TimeEnd,intL_Bull_Val_End); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_COLOR,clrGreenYellow);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_WIDTH,0);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTABLE,false); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTED,false);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_HIDDEN,true);                 
                        
            //ramka
            ObjectCreate(ChartID(),strL_RecName,OBJ_RECTANGLE,intG_WinIdx,dttL_TimeBeg,intL_Bull_Val_Beg,dttL_TimeEnd,intL_Bull_Val_End); 
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_COLOR,clrGreen); 
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_WIDTH,3);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_BACK,false);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_SELECTABLE,false); 
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_SELECTED,false);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_HIDDEN,true);                 
                         
         }
      }
   }   
   }
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////      
   if(enmG_TF_3rd!=enmG_TF_2nd)
   {   
   for (int i=Bars-20;i>=0;i--)//znajduję piewrszy punkt
   {
      //znajdowanie pierwszych parametrów
      if(arr_RSI_HHTF[i]>=intL_Sell_Sig)
      {          
         intL_TimeBeg=i;
         for (int j=i-1;j>=0;j--)// znajduję drugi punkt
         if(arr_RSI_HHTF[j]<intL_Sell_Sig || j == 0)
         {
            intL_TimeEnd=j;
            i=j;
            break;
         }
      // - - - rysowanie prostokąta
         if(intL_TimeBeg>intL_TimeEnd)
         {
            //licznik prostokątów OB
            intG_Rec_OB_No++;
            
            string strL_NoOf_OB_Bar=StringConcatenate(IntegerToString(intG_Rec_OB_No)," ",IntegerToString(MathRand()));
            string strL_RecName=StringConcatenate("OB#",strG_TF_3rd," ",strL_NoOf_OB_Bar);
            string strL_RecName2=StringConcatenate(strL_RecName,"|");
      
            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg=Time[intL_TimeBeg];
            datetime dttL_TimeEnd=Time[intL_TimeEnd];
                    
            //ramka
            ObjectCreate(ChartID(),strL_RecName,OBJ_RECTANGLE,intG_WinIdx,dttL_TimeBeg,intL_Bear_Val_Beg_hhtf,dttL_TimeEnd,intL_Bear_Val_End_hhtf); 
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_COLOR,clrMagenta);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_WIDTH,4);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_BACK,false);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_SELECTABLE,false); 
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_SELECTED,false);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_HIDDEN,true);                 
                               
          }
      }
   }


   for (int i=Bars-20;i>=0;i--)//znajduję piewrszy punkt
   {
      //znajdowanie pierwszych parametrów
      if(arr_RSI_HHTF[i]<=intL_Buy_Sig)
      {        
         intL_Bull_TimeBeg=i;
         for (int j=i-1;j>=0;j--)// znajduję drugi punkt
         if(arr_RSI_HHTF[j]>intL_Buy_Sig || j == 0)
         {
            intL_Bull_TimeEnd=j;
            i=j;
            break;
            
         }
         
      // - - - rysowanie prostokąta
         if(intL_Bull_TimeBeg>intL_Bull_TimeEnd)
         {  
            //licznik prostokątów OS
            intG_Rec_OS_No++;

            string strL_NoOf_OS_Bar=StringConcatenate(IntegerToString(intG_Rec_OS_No)," ",IntegerToString(MathRand()));
            string strL_RecName=StringConcatenate("OS#",strG_TF_3rd," ",strL_NoOf_OS_Bar);
            string strL_RecName2=StringConcatenate(strL_RecName,"|");   
      
            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg=Time[intL_Bull_TimeBeg];
            datetime dttL_TimeEnd=Time[intL_Bull_TimeEnd];
                 
            //ramka
            ObjectCreate(ChartID(),strL_RecName,OBJ_RECTANGLE,intG_WinIdx,dttL_TimeBeg,intL_Bull_Val_Beg_hhtf,dttL_TimeEnd,intL_Bull_Val_End_hhtf); 
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_COLOR,clrAqua); 
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_WIDTH,4);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_BACK,false);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_SELECTABLE,false); 
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_SELECTED,false);
            ObjectSetInteger(ChartID(),strL_RecName,OBJPROP_HIDDEN,true);                 
                        
         }
      }
   }
   }
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{

      //przesuvanie guzikov.
      //20180829 dodaję dzisisj funckonalność przesuania zestavu elliottóv
      if(sparam==strG_RSI_Arr_Up)
      {
         move_Elliott_Up();//)  move_Buttons(0,intG_Step_V);
         ObjectSetInteger(ChartID(),strG_RSI_Arr_Up,OBJPROP_STATE,false);
         
      }
      if(sparam==strG_RSI_Arr_Dn)
      {
         move_Elliott_Dn();//)  move_Buttons(0,-intG_Step_V);      
         ObjectSetInteger(ChartID(),strG_RSI_Arr_Dn,OBJPROP_STATE,false);
      }
      
      
      //guziki
      if (sparam == strG_RSI_ell_1)      
      {
         bool blnL_Button_State = ObjectGetInteger(ChartID(),strG_RSI_ell_1,OBJPROP_STATE);
         if(blnL_Button_State)
         {
            switch_off_elliott_buttons();
            delete_Waves();
            add_Waves(1);
            ObjectSetInteger(ChartID(),strG_RSI_ell_1,OBJPROP_STATE,true);
         }
         else
         {
            ObjectSetInteger(ChartID(),strG_RSI_ell_1,OBJPROP_STATE,false);
            delete_Waves();
         }
      }
      
      if (sparam == strG_RSI_ell_2)      
      {
         bool blnL_Button_State = ObjectGetInteger(ChartID(),strG_RSI_ell_2,OBJPROP_STATE);
         if(blnL_Button_State)
         {
            switch_off_elliott_buttons();
            delete_Waves();
            add_Waves(2);
            ObjectSetInteger(ChartID(),strG_RSI_ell_2,OBJPROP_STATE,true);
         }
         else
         {
            ObjectSetInteger(ChartID(),strG_RSI_ell_2,OBJPROP_STATE,false);
            delete_Waves();
         }
      }

      if (sparam == strG_RSI_ell_3)      
      {
         bool blnL_Button_State = ObjectGetInteger(ChartID(),strG_RSI_ell_3,OBJPROP_STATE);
         if(blnL_Button_State)
         {
            switch_off_elliott_buttons();
            delete_Waves();
            add_Waves(3);
            ObjectSetInteger(ChartID(),strG_RSI_ell_3,OBJPROP_STATE,true);
         }
         else
         {
            ObjectSetInteger(ChartID(),strG_RSI_ell_3,OBJPROP_STATE,false);
            delete_Waves();
         }
      }
      

      if (sparam == strG_RSI_ell_4)      
      {
         bool blnL_Button_State = ObjectGetInteger(ChartID(),strG_RSI_ell_4,OBJPROP_STATE);
         if(blnL_Button_State)
         {
            switch_off_elliott_buttons();
            delete_Waves();
            add_Waves(4);
            ObjectSetInteger(ChartID(),strG_RSI_ell_4,OBJPROP_STATE,true);
         }
         else
         {
            ObjectSetInteger(ChartID(),strG_RSI_ell_4,OBJPROP_STATE,false);
            delete_Waves();
         }
      }
      if (sparam == strG_RSI_ell_5)      
      {
         bool blnL_Button_State = ObjectGetInteger(ChartID(),strG_RSI_ell_5,OBJPROP_STATE);
         if(blnL_Button_State)
         {
            switch_off_elliott_buttons();
            delete_Waves();
            add_Waves(5);
            ObjectSetInteger(ChartID(),strG_RSI_ell_5,OBJPROP_STATE,true);
         }
         else
         {
            ObjectSetInteger(ChartID(),strG_RSI_ell_5,OBJPROP_STATE,false);
            delete_Waves();
         }
      }
}
//
bool switch_off_elliott_buttons()
{
   ObjectSetInteger(ChartID(),strG_RSI_ell_1,OBJPROP_STATE,false);
   ObjectSetInteger(ChartID(),strG_RSI_ell_2,OBJPROP_STATE,false);
   ObjectSetInteger(ChartID(),strG_RSI_ell_3,OBJPROP_STATE,false);
   ObjectSetInteger(ChartID(),strG_RSI_ell_4,OBJPROP_STATE,false);
   return true;
}
//+------------------------------------------------------------------+ 
//|                        Buttons                                   | 
//+------------------------------------------------------------------+
bool show_AllButtonsOnScreen()
{
   //guziki
   delete_Buttons();
   intG_WinIdx = WindowFind(strG_NazwaIndi);

   create_Button(ChartID(),strG_RSI_Arr_Up,intG_WinIdx,intU_X,      31,  12,26,CORNER_LEFT_LOWER,"^","Arial",8,clrNavy,clrPowderBlue);
   create_Button(ChartID(),strG_RSI_Arr_Dn,intG_WinIdx,intU_X+12*3, 31,  12,26,CORNER_LEFT_LOWER,"v","Arial",8,clrNavy,clrPowderBlue);
   
   create_Button(ChartID(),strG_RSI_ell_1,intG_WinIdx,intU_X+12*1, 31,  12,13,CORNER_LEFT_LOWER,"1","Arial",8);
   create_Button(ChartID(),strG_RSI_ell_2,intG_WinIdx,intU_X+12*2, 31,  12,13,CORNER_LEFT_LOWER,"2","Arial",8);
   create_Button(ChartID(),strG_RSI_ell_3,intG_WinIdx,intU_X+12*1, 18,  12,13,CORNER_LEFT_LOWER,"3","Arial",8);
   create_Button(ChartID(),strG_RSI_ell_4,intG_WinIdx,intU_X+12*2, 18,  12,13,CORNER_LEFT_LOWER,"4","Arial",8);
   create_Button(ChartID(),strG_RSI_ell_5,intG_WinIdx,intU_X+12*1.5, 44,  12,13,CORNER_LEFT_LOWER,"a","Arial",8);
   

   return true;
}
//+------------------------------------------------------------------+
void delete_Buttons()
{
   ObjectDelete(strG_RSI_Arr_Up);
   ObjectDelete(strG_RSI_Arr_Dn);
   ObjectDelete(strG_RSI_ell_1);
   ObjectDelete(strG_RSI_ell_2);
   ObjectDelete(strG_RSI_ell_3);
   ObjectDelete(strG_RSI_ell_4);
   ObjectDelete(strG_RSI_ell_5);
}
//+------------------------------------------------------------------+ 
bool move_Elliott_Up()
{
   //20180829
   long lngL_ID = ChartID();
   bool blnL_return = false;
   int intL_ObjTotal=ObjectsTotal();
   string strL_Name; 
   for(int i=0;i<intL_ObjTotal;i++) 
   { 
      strL_Name = ObjectName(i);
      if(StringSubstr      (strL_Name,0,2) == "el")
      if(ObjectGetInteger  (lngL_ID,strL_Name,OBJPROP_SELECTED))
      {
         datetime dttL_Time = ObjectGetInteger(lngL_ID,strL_Name,OBJPROP_TIME);
         double   dlbL_Ptice = ObjectGetDouble (lngL_ID,strL_Name,OBJPROP_PRICE);  
         double dblL_Step = 10;      
         ObjectMove(lngL_ID,strL_Name,0,dttL_Time,dlbL_Ptice + dblL_Step);
         blnL_return = true;
      }
   }
   return blnL_return;
}
//+------------------------------------------------------------------+ 
bool move_Elliott_Dn()
{
   //20180829
   long lngL_ID = ChartID();   
   bool blnL_return = false;   
   int intL_ObjTotal=ObjectsTotal(); 
   string strL_Name; 
   for(int i=0;i<intL_ObjTotal;i++) 
   { 
      strL_Name = ObjectName(i);
      if(StringSubstr      (strL_Name,0,2) == "el")
      if(ObjectGetInteger  (lngL_ID,strL_Name,OBJPROP_SELECTED))
      {
         datetime dttL_Time = ObjectGetInteger(lngL_ID,strL_Name,OBJPROP_TIME);
         double   dlbL_Ptice = ObjectGetDouble (lngL_ID,strL_Name,OBJPROP_PRICE);  
         double dblL_Step = 10;
         ObjectMove(lngL_ID,strL_Name,0,dttL_Time,dlbL_Ptice - dblL_Step);
         blnL_return = true;
      }
   }
   return blnL_return; 
}
////+------------------------------------------------------------------+
void add_Waves(int head_whichWaves)
{
   //20180808-20180902-20190311
   
   string strL_font_type;
   int    intL_font_size; 
   color  clrL_font_color;
   
        if(head_whichWaves == 1)   { strL_font_type = "Arial";          intL_font_size = 10; clrL_font_color = clrGold;       print_elliott_letters(strL_font_type, intL_font_size,clrL_font_color,col_fale_RomanBracekt);}
   else if(head_whichWaves == 2)   { strL_font_type = "Arial Black";    intL_font_size = 12; clrL_font_color = clrGold;       print_elliott_letters(strL_font_type, intL_font_size,clrL_font_color,col_fale_Roman);}
   else if(head_whichWaves == 3)   { strL_font_type = "Arial";          intL_font_size = 16; clrL_font_color = clrAqua;       print_elliott_letters(strL_font_type, intL_font_size,clrL_font_color,col_fale_Small);}
   else if(head_whichWaves == 4)   { strL_font_type = "Arial Black";    intL_font_size = 20; clrL_font_color = clrDarkOrchid; print_elliott_letters(strL_font_type, intL_font_size,clrL_font_color,col_fale_Capital);}
   else if(head_whichWaves == 5)   { strL_font_type = "Century Gothic"; intL_font_size = 14; clrL_font_color = clrSilver;     print_elliott_letters(strL_font_type, intL_font_size,clrL_font_color,col_fale_ALT);}
}

//+------------------------------------------------------------------+
void print_elliott_letters(string head_Font, int head_FontSize, color head_Color,string& head_kolekcja[], const string head_extention = "lev", const double head_Y = 15)
{
   //20180828
   int intL_WinIdx = WindowFind(strG_NazwaIndi);
   int intL_BarsOnChart = WindowBarsPerChart();
   int intL_Bar_First   = WindowFirstVisibleBar() - intL_BarsOnChart * 0.9;   if(intL_Bar_First <0) intL_Bar_First = 0;
   int intL_Size        = ArraySize(head_kolekcja);
   int intL_Step        = MathRound(intL_BarsOnChart*.4/13);   //było 17 na początku
      
   for(int i=0;i<intL_Size;i++)
   {
      string strL_col_n = head_kolekcja[i];
      string strL_Name_Base = "el "  + head_extention + " " + strL_col_n;
      string strL_Name = strL_Name_Base;
      int j=0;      
      if(ObjectFind(ChartID(),strL_Name)>-1)
      do
      {
         j++;
         
         strL_Name = strL_Name_Base + " " + IntegerToString(j);
         if (j>144) break;
      }
      while(ObjectFind(ChartID(),strL_Name)>-1 && !IsStopped());
      create_Text(ChartID(),strL_Name,intL_WinIdx,Time[intL_Bar_First+(intL_Size-i)*intL_Step],head_Y,strL_col_n,head_Font,      head_FontSize, head_Color,   0,ANCHOR_LEFT_UPPER,false,true,false);
   }
}
//+------------------------------------------------------------------+
void delete_Waves()
{
//20190105 kasuje aktywne elliotty
   bool blnL_f = true;
   int intL_p=0;
   while(blnL_f && !IsStopped()) 
   { 
      blnL_f = false;
      intL_p++;
      //Alert("przelot ",intL_p," objektów=",ObjectsTotal(lngG_ID,0,OBJ_TEXT));
      int intL_IleTxt = ObjectsTotal();//lngG_ID,0,OBJ_TEXT
      for(int i=0;i<intL_IleTxt;i++)
      {
         string strL_TxtName = ObjectName(i);
         //
         if(StringSubstr(strL_TxtName,0,2) == "el")
         if(ObjectGetInteger(lngG_ID,strL_TxtName,OBJPROP_SELECTED,true))
         {
            ObjectDelete(strL_TxtName);
            blnL_f = true;
         }
      }  
   }
}
