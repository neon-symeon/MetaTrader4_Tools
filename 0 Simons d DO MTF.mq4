//+------------------------------------------------------------------+
//|          Simon's Dynamic Oscillator MultiTimeFrame Look Back.mq4 |
//|                                                     Szymon Marek |
//|                                       http://www.SzymonMarek.com |
//+------------------------------------------------------------------+

//20170919 triple time frame
#property copyright "(c) Szymon Marek 2014-2018"
#property link      "www.SzymonMarek.com"
#property version   "1.00"
#property description "Simon's MultiTimeFrame & Triple Look Back Dynamic Oscylator"
#property description " "
#property description "Szczegóły opisu ustawień w oscylatorze bazowym Simons DO"
#property description "Paski reprezentują stany OB/OS oscylatora na  wyższych interwałach lub na wyższych ustawieniach parametrów DO. Opis paska po najechaniu nań myszką."
#property description "Kropki i strzałki syntetycznie pokazują nabardziej prawdopodobne miejsca zmiany kierunku."
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property indicator_level1 20
#property indicator_level2 50
#property indicator_level3 80
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT
//+------------------------------------------------------------------+
#property indicator_buffers 8
//+------------------------------------------------------------------+
#property indicator_color1 clrAqua
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

#property indicator_color2 clrMagenta
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

#property indicator_color3 clrAqua 
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

#property indicator_color4 clrMagenta
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
//strzalki
#property indicator_color5 clrLime
#property indicator_width5 1
#property indicator_color6 clrRed
#property indicator_width6 1
//strzalki
#property indicator_color7 clrLime
#property indicator_width7 1
#property indicator_color8 clrRed
#property indicator_width8 1

double arr_FastLine[];
double arr_SlowLine[];
double arr_FastLine_DLB[];
double arr_SlowLine_DLB[];
double arr_BullDot[];
double arr_BearDot[];
double arr_BullArrow[];
double arr_BearArrow[];
//nie pokazuje ale z tego robi strzałki lub paski
double arr_FastLine_TLB[];
double arr_SlowLine_TLB[];
double arr_FastLine_HTF_1[];
double arr_SlowLine_HTF_1[];
double arr_FastLine_HTF_2[];
double arr_SlowLine_HTF_2[];
//+------------------------------------------------------------------+
//zmienne zewnętrzne
//+------------------------------------------------------------------+
extern string           s0="--- Pierwsza Para ---";  //---
extern bool                blnE_Czy_P1             = true;           //Czy Szybkie Linie Oscylatora
extern ENUMS_DO_SET        enmE_DO_Set_TTF         = set_Auto;       //Parametr DO
extern ENUMS_DO_Line       enmE_DO_Line_TTF        = line_slow;
extern string           s1="--- Druga Para ---";  //---
extern bool                blnE_Czy_P2             = false;           //Czy Wolniejsze Linie Oscylatora
extern ENUMS_DO_SET        enmE_DO_Set_TTF_DLB     = set_Auto;       //Parametr DO
extern ENUMS_DO_Line       enmE_DO_Line_TTF_DLB    = line_slow;
extern string           s2="--- Pierwszy Pasek TTF ---";  //---
extern bool                blnE_Czy_P3_Strap       = true;           //Czy Wolny Pasek (pierwszy)
extern ENUMS_DO_SET        enmE_DO_Set_TTF_TLB     = set_Auto;       //Parametr DO
extern ENUMS_DO_Line       enmE_DO_Line            = line_fast;      //Która Linia Ma Wejść Do Strefy
extern color               clrE_TTF_OB             = clrLime;        
extern color               clrE_TTF_OS             = clrRed;
extern string           s3 = " --- Dwa Paski HTF ---";  //---
extern bool                blnE_Czy_HTF1_Strap     = true;           //Czy HTF Pasek (drugi)
extern ENUMS_DO_SET        enmE_DO_Set_HTF_1       = set_1;          //Parametr DO dla wyższego interwału
extern ENUM_TIMEFRAMES     enmE_Period_HTF_1       = PERIOD_CURRENT; //interwał (Current = Auto)
extern ENUMS_DO_Line       enmE_DO_Line_HTF_1      = line_fast;      //Która Linia Ma Wejść Do Strefy
extern bool                blnE_Czy_HTF2_Strap     = true;           //Czy HTF Pasek (trzeci przenikający)
extern ENUMS_DO_SET        enmE_DO_Set_HTF_2       = set_1;          //Parametr DO dla jeszcze wyższego interwału
extern ENUM_TIMEFRAMES     enmE_Period_HTF_2       = PERIOD_CURRENT; //interwał (Current = Auto)
extern ENUMS_DO_Line       enmE_DO_Line_HTF_2      = line_fast;      //Która Linia Ma Wejść Do Strefy

extern string           s4 = "--- Czy Wyświetlać Odczyty DO ---";  //---
extern bool                blnE_Display_DO_Readings    = true;
extern string           s5="--- Alert automatycznych sygnałów Buy/Sell ---";  //---
extern bool                blnE_Czy_Alerts = false;

//+------------------------------------------------------------------+
//globalne zmienne
//+------------------------------------------------------------------+
int      intG_WinIdx;                                                //indeks okna wskaźnika
string   strG_NazwaIndi;                                             //nazwa indykatora
ENUMS_DO_SET      enmG_DO_Set_1st, enmG_DO_Set_2nd, enmG_DO_Set_3rd; //dto settings ttf
ENUM_TIMEFRAMES   enmG_TF_1st,enmG_TF_2nd, enmG_TF_3rd;              //multi time frame settings all
string            strG_TF_1st,strG_TF_2nd, strG_TF_3rd;
string strG_Readings_TTF_1 = "DO MTF Readings TTF 1";                    //DO readings
string strG_Readings_TTF_2 = "DO MTF Readings TTF 2";
string strG_Readings_HTF_1 = "DO MTF Readings HTF 1";
string strG_Readings_HTF_2 = "DO MTF Readings HTF 2";
string strG_Shade_Readings = "DO MTF Shade";
bool blnG_Czy_Alerts = true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- dokładność wyświetleń
   IndicatorDigits(1);
   //ogarnia timeframe'y
                                             enmG_TF_1st  = Period();                           
   if(enmE_Period_HTF_1 == PERIOD_CURRENT)   enmG_TF_2nd  = convert_TF_To_H_TF(enmG_TF_1st);  else enmG_TF_2nd = enmE_Period_HTF_1;
   if(enmE_Period_HTF_2 == PERIOD_CURRENT)   enmG_TF_3rd  = convert_TF_To_HH_TF(enmG_TF_1st); else enmG_TF_3rd = enmE_Period_HTF_2;
   
   strG_TF_1st = translate_TF(enmG_TF_1st);
   strG_TF_2nd = translate_TF(enmG_TF_2nd);
   strG_TF_3rd = translate_TF(enmG_TF_3rd);
   
   //--- ogarnia ustawienia DO
   if(enmE_DO_Set_TTF     == set_Auto)    enmG_DO_Set_1st = set_1;                                                               else  enmG_DO_Set_1st = enmE_DO_Set_TTF;
   if(enmE_DO_Set_TTF_DLB == set_Auto)    enmG_DO_Set_2nd = convert_DO_Auto_Settings(enmG_DO_Set_1st);                           else  enmG_DO_Set_2nd = enmE_DO_Set_TTF_DLB;
   if(enmE_DO_Set_TTF_TLB == set_Auto)    enmG_DO_Set_3rd = convert_DO_Auto_Settings(MathMax(enmG_DO_Set_1st,enmG_DO_Set_2nd));  else  enmG_DO_Set_3rd = enmE_DO_Set_TTF_TLB;

   //--- nazwa oscylatora, gdy wszystko już ustawione
   strG_NazwaIndi = "Simon's MultiTimeFrame DO|";
   
   if(blnE_Czy_P1 || blnE_Czy_P2 || blnE_Czy_P3_Strap)      strG_NazwaIndi = strG_NazwaIndi + strG_TF_1st + ".";
   if(blnE_Czy_P1)                                          strG_NazwaIndi = strG_NazwaIndi + translate_DO_settings(enmG_DO_Set_1st);
   if(blnE_Czy_P1 && blnE_Czy_P2)                           strG_NazwaIndi = strG_NazwaIndi + ".";
   if(blnE_Czy_P2)                                          strG_NazwaIndi = strG_NazwaIndi + translate_DO_settings(enmG_DO_Set_2nd);
   if( (blnE_Czy_P1 || blnE_Czy_P2) && blnE_Czy_P3_Strap)   strG_NazwaIndi = strG_NazwaIndi + ".";
   if(blnE_Czy_P3_Strap)                                    strG_NazwaIndi = strG_NazwaIndi + translate_DO_settings(enmG_DO_Set_3rd);
   strG_NazwaIndi = strG_NazwaIndi + "|";
   strG_NazwaIndi = strG_NazwaIndi + strG_TF_2nd + "." + translate_DO_settings(enmE_DO_Set_HTF_1) + ";";
   strG_NazwaIndi = strG_NazwaIndi + strG_TF_3rd + "." + translate_DO_settings(enmE_DO_Set_HTF_2) + "|";
   if(blnE_Czy_Alerts)                                      strG_NazwaIndi = strG_NazwaIndi + " ALERTS";

   IndicatorShortName(strG_NazwaIndi); 

   //--- mapowanie
   IndicatorBuffers(16);
   SetIndexBuffer(0,arr_FastLine);        SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,arr_SlowLine);        SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,arr_FastLine_DLB);    SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(3,arr_SlowLine_DLB);    SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(4,arr_BullDot);         SetIndexStyle(4,DRAW_ARROW);SetIndexArrow(4,159);SetIndexEmptyValue(4,0.0);
   SetIndexBuffer(5,arr_BearDot);         SetIndexStyle(5,DRAW_ARROW);SetIndexArrow(5,159);SetIndexEmptyValue(5,0.0);
   SetIndexBuffer(6,arr_BullArrow);       SetIndexStyle(6,DRAW_ARROW);SetIndexArrow(6,233);SetIndexEmptyValue(6,0.0);
   SetIndexBuffer(7,arr_BearArrow);       SetIndexStyle(7,DRAW_ARROW);SetIndexArrow(7,234);SetIndexEmptyValue(7,0.0);
      
   SetIndexBuffer(10,arr_FastLine_TLB);
   SetIndexBuffer(11,arr_SlowLine_TLB);
   SetIndexBuffer(12,arr_FastLine_HTF_1);
   SetIndexBuffer(13,arr_SlowLine_HTF_1);
   SetIndexBuffer(14,arr_FastLine_HTF_2);
   SetIndexBuffer(15,arr_SlowLine_HTF_2);  

   SetIndexLabel(0,"Fast Line");
   SetIndexLabel(1,"Slow Line");
   SetIndexLabel(2,"DLB: Fast Line");
   SetIndexLabel(3,"DLB: Slow Line");   
   SetIndexLabel(4,"MultiTimeFrame BULL Signal");
   SetIndexLabel(5,"MultiTimeFrame BEAR Signal");   
   SetIndexLabel(6,"MultiTimeFrame BULL Signal");
   SetIndexLabel(7,"MultiTimeFrame BEAR Signal");   

   //wykluczenia
   if(!blnE_Czy_P1)
   {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
   }
   if(!blnE_Czy_P2)
   {
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
   }
     
   intG_WinIdx=WindowFind(strG_NazwaIndi);
   
   if(!blnE_Czy_P3_Strap) delete_All_Straps_and_Boxes(strG_NazwaIndi);
   
   //readings
   if(blnE_Display_DO_Readings)show_Readings();else delete_Readings();
   
   return(INIT_SUCCEEDED);
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
   //zakresy obliczeń
   int intL_BTC_TTF  = rates_total-prev_calculated+1;
   int intL_BTC_HTF  = intL_BTC_TTF;
   //początek obliczeń
   if       (prev_calculated==0)          //dla pierwszego przelotu
   {
      intL_BTC_TTF   = Bars - calc_DO_Begin(enmG_DO_Set_1st,enmG_DO_Set_2nd,enmG_DO_Set_3rd);;
      intL_BTC_HTF   = intL_BTC_TTF; 
   }
   else if  (prev_calculated==rates_total)//przelicza tylko ostatni
   {
      intL_BTC_TTF   = 0;
      intL_BTC_HTF   = 0;
   }
   else
   {
      //
      blnG_Czy_Alerts = true;
      //
      if  (iBarShift(NULL,enmG_TF_3rd,Time[0]) != iBarShift(NULL,enmG_TF_3rd,Time[0]))
      {
         for(int i=2;i<Bars-50;i++)
         if(iBarShift(NULL,enmG_TF_3rd,Time[i])!= iBarShift(NULL,enmG_TF_3rd,Time[i+1]))
         {
            intL_BTC_HTF  = i+1;
            //Alert("TF=",strG_TF_1st,"; ",Symbol()," ",strG_TF_3rd," ",strG_NazwaIndi," Bars To Calculate: ",intL_BTC_HTF);            
            break;
         }
      } 
      else if  (iBarShift(NULL,enmG_TF_2nd,Time[0]) != iBarShift(NULL,enmG_TF_2nd,Time[1]))
      {
         for(int i=2;i<Bars-50;i++)
         if(iBarShift(NULL,enmG_TF_2nd,Time[i])!= iBarShift(NULL,enmG_TF_2nd,Time[i+1]))
         {
            intL_BTC_HTF  = i+1;
            //Alert("TF=",strG_TF_1st,"; ",Symbol()," ",strG_TF_3rd," ",strG_NazwaIndi," Bars To Calculate: ",intL_BTC_HTF);            
            break;
         }
      }   
   }   
   //Lines TTF
   for (int i=0;i<=intL_BTC_TTF;i++)
   {
      arr_FastLine[i] = calc_DO_single_line(0,enmG_DO_Set_1st,line_fast,i);
      arr_SlowLine[i] = calc_DO_single_line(0,enmG_DO_Set_1st,line_slow,i);

      if(blnE_Czy_P2)
      {
         arr_FastLine_DLB[i]= calc_DO_single_line(0,enmG_DO_Set_2nd,line_fast,i);
         arr_SlowLine_DLB[i]= calc_DO_single_line(0,enmG_DO_Set_2nd,line_slow,i);
      }
      if(blnE_Czy_P3_Strap)
      {
         arr_FastLine_TLB[i]= calc_DO_single_line(0,enmG_DO_Set_3rd,line_fast,i);
         arr_SlowLine_TLB[i]= calc_DO_single_line(0,enmG_DO_Set_3rd,line_slow,i);
      }
   }
   // w tle htf
   for (int i=0;i<intL_BTC_HTF;i++)
   {
      int intL_HTF = iBarShift(NULL,enmG_TF_2nd,Time[i]);
      arr_FastLine_HTF_1[i]= calc_DO_single_line(enmG_TF_2nd,enmE_DO_Set_HTF_1,line_fast,intL_HTF);
      arr_SlowLine_HTF_1[i]= calc_DO_single_line(enmG_TF_2nd,enmE_DO_Set_HTF_1,line_slow,intL_HTF);     
      
      int intL_HHTF = iBarShift(NULL,enmG_TF_3rd,Time[i]);   
      arr_FastLine_HTF_2[i]= calc_DO_single_line(enmG_TF_3rd,enmE_DO_Set_HTF_2,line_fast,intL_HHTF);
      arr_SlowLine_HTF_2[i]= calc_DO_single_line(enmG_TF_3rd,enmE_DO_Set_HTF_2,line_slow,intL_HHTF);
   }
   //arrows
   for (int i=0;i<intL_BTC_HTF;i++)
   {
      arr_BullArrow[i] = 0; arr_BearArrow[i] = 0; arr_BullDot[i] = 0; arr_BearDot[i] = 0;
      
      if((arr_FastLine_HTF_1[i]  > arr_SlowLine_HTF_1[i]) || (arr_FastLine_HTF_2[i]  > arr_SlowLine_HTF_2[i]) )
      {
         if( arr_FastLine[i]  > arr_SlowLine[i] &&  arr_FastLine[i+1] < arr_SlowLine[i+1] )
         if( arr_SlowLine[i]  < indicator_level2)
            arr_BullArrow[i] = indicator_level1 + 10;
         
         if(arr_SlowLine[i]<20) arr_BullDot[i] = indicator_level1+2;
      }   
      if((arr_FastLine_HTF_1[i] < arr_SlowLine_HTF_1[i]) || (arr_FastLine_HTF_2[i] < arr_SlowLine_HTF_2[i]))
      {
         if( arr_FastLine[i] < arr_SlowLine[i]  && arr_FastLine[i+1] > arr_SlowLine[i+1])
         if( arr_SlowLine[i] > indicator_level2)   
            arr_BearArrow[i] = indicator_level3 - 10;
   
         if(arr_SlowLine[i]>80) arr_BearDot[i] = indicator_level3-2;
      }
   }
   //strefy draw_OBOS_Straps
   if(prev_calculated!=rates_total)  
   {
      //ogrania paski obos
      intG_WinIdx = WindowFind(strG_NazwaIndi);
      delete_All_Straps_and_Boxes(intG_WinIdx);
      //ttf
      if       (enmE_DO_Line == line_slow)   draw_OBOS_Straps(arr_SlowLine_TLB,  1);
      else if  (enmE_DO_Line == line_fast)   draw_OBOS_Straps(arr_FastLine_TLB,  1);
      //htf 1
      if(blnE_Czy_HTF1_Strap)
         draw_OBOS_Straps(arr_SlowLine_HTF_1,2);
      //htf 2      
      if(blnE_Czy_HTF2_Strap)
      if(enmG_TF_2nd != enmG_TF_3rd)
         draw_OBOS_Straps(arr_SlowLine_HTF_2,3);
   }
   
   //ogrania odczyty DO
   if(blnE_Display_DO_Readings) manage_Readings();
   //alerty
   manage_Alerts();
   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+ 
//| --- Dynamic Oscillator Readings on the Screen ---                | 
//+------------------------------------------------------------------+ 
bool show_Readings()
{
   if(!blnE_Display_DO_Readings) return false;  //jak nie to nie
   //ustawienia zmiennych
   intG_WinIdx=WindowFind(strG_NazwaIndi);      //dla pewności 
   int intL_X = intU_X,  intL_Y = 20;               
   int intL_H = 33;                             //wysokość cienia

   if(enmG_TF_3rd!=enmG_TF_2nd || enmE_DO_Set_HTF_1!=enmE_DO_Set_HTF_2) intL_H = intL_H + 28;
   else                                                                 intL_H = intL_H + 14;
   
   color clrL_Shade = ChartGetInteger(ChartID(),CHART_COLOR_BACKGROUND); //cień w kolorze tła
   //kasowanie poprzednich wynków
   delete_Readings();
   //tworzenie nowych
   create_RectLabel (ChartID(),strG_Shade_Readings,intG_WinIdx,intL_X,intL_Y,144,intL_H,clrL_Shade);//,BORDER_FLAT,CORNER_LEFT_UPPER);
   intL_Y = intL_Y + 4; //leciutki margines
                                 
                                                                                                            create_Label(ChartID(),strG_Readings_TTF_1,  intG_WinIdx,intL_X+6,intL_Y+13*1, CORNER_LEFT_UPPER,"R1","Arial",8);
   if(check_dif_DO_set_4_display(enmG_TF_1st,enmG_DO_Set_1st,enmG_TF_1st,enmG_DO_Set_2nd))                  create_Label(ChartID(),strG_Readings_TTF_2,  intG_WinIdx,intL_X+6,intL_Y+13*2, CORNER_LEFT_UPPER,"R2","Arial",8);
                                                                                                            create_Label(ChartID(),strG_Readings_HTF_1,  intG_WinIdx,intL_X+6,intL_Y+13*3, CORNER_LEFT_UPPER,"R3","Arial",8);
   if(check_dif_DO_set_4_display(enmG_TF_2nd,enmE_DO_Set_HTF_1,enmG_TF_3rd,enmE_DO_Set_HTF_2))              create_Label(ChartID(),strG_Readings_HTF_2,  intG_WinIdx,intL_X+6,intL_Y+13*4, CORNER_LEFT_UPPER,"R4","Arial",8);
   //
   return true;
}
//+------------------------------------------------------------------+
bool manage_Readings()
{
   //abstrakt 20180905
   if(!blnE_Display_DO_Readings) return false;

   calc_Readings(0); calc_Readings(1); calc_Readings(2); calc_Readings(3);
   
   int intL_StringLen = calculate_Shadow_Len(strG_Readings_TTF_1,strG_Readings_TTF_2,strG_Readings_HTF_1,strG_Readings_HTF_2);
   ObjectSetInteger(ChartID(),strG_Shade_Readings,OBJPROP_XSIZE,intL_StringLen);
   
   if       (arr_FastLine_TLB[0]>80)   ObjectSetInteger(ChartID(),strG_Shade_Readings, OBJPROP_COLOR,clrRed);
   else if  (arr_FastLine_TLB[0]<20)   ObjectSetInteger(ChartID(),strG_Shade_Readings, OBJPROP_COLOR,clrGreen);
   else                                ObjectSetInteger(ChartID(),strG_Shade_Readings, OBJPROP_COLOR,clrSilver);
   
   return true;
}
//+------------------------------------------------------------------+
bool calc_Readings(int head_level)
{
   ENUM_TIMEFRAMES   enmL_TimeFrame = 0;
   ENUMS_DO_SET      enmL_DO_Set    = 1;
   string            strL_TF        = "";

   if(head_level == 0)
   {
      enmL_TimeFrame = 0;  enmL_DO_Set = enmG_DO_Set_1st;
      strL_TF = strG_TF_1st;
   }
   if(head_level == 1)
   {
      enmL_TimeFrame = 0;  enmL_DO_Set = enmG_DO_Set_2nd;
      strL_TF = strG_TF_1st;
   }
   if(head_level == 2)
   {
      enmL_TimeFrame = enmG_TF_2nd;  enmL_DO_Set = enmE_DO_Set_HTF_1;
      strL_TF = strG_TF_2nd;
   }
   if(head_level == 3)
   {
      enmL_TimeFrame = enmG_TF_3rd;  enmL_DO_Set = enmE_DO_Set_HTF_2;
      strL_TF = strG_TF_3rd;
   }
   double dblL_FL_0 = calc_DO_single_line(enmL_TimeFrame,enmL_DO_Set,line_fast,0);
   double dblL_SL_0 = calc_DO_single_line(enmL_TimeFrame,enmL_DO_Set,line_slow,0);
   double dblL_FL_1 = calc_DO_single_line(enmL_TimeFrame,enmL_DO_Set,line_fast,1);
   double dblL_SL_1 = calc_DO_single_line(enmL_TimeFrame,enmL_DO_Set,line_slow,1);
   double dblL_FL_2 = calc_DO_single_line(enmL_TimeFrame,enmL_DO_Set,line_fast,2);
   double dblL_SL_2 = calc_DO_single_line(enmL_TimeFrame,enmL_DO_Set,line_slow,2);

   string strL_DO_state_0 = translate_DO_state(read_DO_State(dblL_FL_0,dblL_SL_0,dblL_FL_1,dblL_SL_1));
   string strL_DO_state_1 = translate_DO_state(read_DO_State(dblL_FL_1,dblL_SL_1,dblL_FL_2,dblL_SL_2));
   
   string strL_Text = strL_TF  + "(" + translate_DO_settings(enmL_DO_Set)+"): " + strL_DO_state_1;      

   if(strL_DO_state_0!=strL_DO_state_1)
   {
      strL_Text = strL_Text + " (>" + strL_DO_state_0+")";;
   }
   
   color  clrL_DO_color = color_DO_Readings(strL_DO_state_1);
   string strL_DO_font  = font_DO_Readings(strL_DO_state_1);
   
   if(head_level == 0)
   {
      ObjectSetString(ChartID(), strG_Readings_TTF_1, OBJPROP_TEXT, strL_Text);
      ObjectSetInteger(ChartID(),strG_Readings_TTF_1, OBJPROP_COLOR,clrL_DO_color);
      ObjectSetString(ChartID(), strG_Readings_TTF_1, OBJPROP_FONT, strL_DO_font);
   }  
   if(head_level == 1)
   {
      ObjectSetString(ChartID(), strG_Readings_TTF_2, OBJPROP_TEXT, strL_Text);
      ObjectSetInteger(ChartID(),strG_Readings_TTF_2, OBJPROP_COLOR,clrL_DO_color);
      ObjectSetString(ChartID(), strG_Readings_TTF_2, OBJPROP_FONT, strL_DO_font);      
   }
   if(head_level == 2)
   {
      ObjectSetString(ChartID(), strG_Readings_HTF_1, OBJPROP_TEXT, strL_Text);
      ObjectSetInteger(ChartID(),strG_Readings_HTF_1, OBJPROP_COLOR,clrL_DO_color);
      ObjectSetString(ChartID(), strG_Readings_HTF_1, OBJPROP_FONT, strL_DO_font);
   }
   if(head_level == 3)
   {
      ObjectSetString(ChartID(), strG_Readings_HTF_2, OBJPROP_TEXT, strL_Text);
      ObjectSetInteger(ChartID(),strG_Readings_HTF_2, OBJPROP_COLOR,clrL_DO_color);
      ObjectSetString(ChartID(), strG_Readings_HTF_2, OBJPROP_FONT, strL_DO_font);
   }
      
   return true;
}
//+------------------------------------------------------------------+
bool delete_Readings()
{
   if(ObjectFind(ChartID(),strG_Shade_Readings) >-1)  ObjectDelete(ChartID(),strG_Shade_Readings);
   if(ObjectFind(ChartID(),strG_Readings_TTF_1) >-1)  ObjectDelete(ChartID(),strG_Readings_TTF_1);
   if(ObjectFind(ChartID(),strG_Readings_TTF_2) >-1)  ObjectDelete(ChartID(),strG_Readings_TTF_2);
   if(ObjectFind(ChartID(),strG_Readings_HTF_1) >-1)  ObjectDelete(ChartID(),strG_Readings_HTF_1);
   if(ObjectFind(ChartID(),strG_Readings_HTF_2) >-1)  ObjectDelete(ChartID(),strG_Readings_HTF_2);
   return true;
}
//+------------------------------------------------------------------+ 
//| --- Straps Creation ---                                          | 
//+------------------------------------------------------------------+ 
bool draw_OBOS_Straps(double &DTO_Line[], int head_level)
//20150913 zacząłem, a teraz (20150914) kontynuuję
//20180904+ do multitimeframelookback MTF
//prostokąty OB/OS
{ 
   
   intG_WinIdx = WindowFind(strG_NazwaIndi);
 
   int      intL_Bear_TimeEnd = 0,  intL_Bear_TimeBeg = 0;
   int      intL_Bull_TimeEnd = 0,  intL_Bull_TimeBeg = 0;
   double   dblL_Bear_ValBeg  = 0,  dblL_Bear_ValEnd = 0,   dblL_Bull_ValBeg = 0,   dblL_Bull_ValEnd = 0;
   color    clrL_bulls = clrGray,   clrL_bears = clrGray;
   string   strL_StrapName;

   if       (head_level == 1)
   {
      dblL_Bear_ValBeg  = 90;       dblL_Bear_ValEnd  = 80;
      dblL_Bull_ValBeg  = 10;       dblL_Bull_ValEnd  = 20;
      clrL_bulls        = clrLime;  clrL_bears = clrRed;
      strL_StrapName    = strG_TF_1st+".("+translate_DO_settings(enmG_DO_Set_3rd)+")";
   }    
   else if  (head_level == 2)
   {
      dblL_Bear_ValBeg  = 92;       dblL_Bear_ValEnd  = 98;
      dblL_Bull_ValBeg  = 08;       dblL_Bull_ValEnd  = 02;
      clrL_bulls        = clrAqua;  clrL_bears = clrMagenta;
      strL_StrapName    = strG_TF_2nd+".("+translate_DO_settings(enmE_DO_Set_HTF_1)+")";
   }    
   else if  (head_level == 3)
   {
      dblL_Bear_ValBeg  = 96;      dblL_Bear_ValEnd  = 93;
      dblL_Bull_ValBeg  = 06;      dblL_Bull_ValEnd  = 03;
      clrL_bulls        = clrGreen; clrL_bears = clrBrown;      
      strL_StrapName    = strG_TF_3rd+".("+translate_DO_settings(enmE_DO_Set_HTF_2)+")";
   }
       
   for (int i=0;i<Bars-20;i++)//znajduję piewrszy punkt
   {
      if(DTO_Line[i] >= indicator_level3)       //znajdowanie pierwszych parametrów
      {          
         intL_Bear_TimeEnd=i;
         for (int j=i+1;j<Bars-20;j++)
         if(DTO_Line[j]<=indicator_level3)      // znajdowanie drugich punktów
         {
            intL_Bear_TimeBeg=j;
            i=j;
            break;
         }
         // - - - rysowanie prostokąta
         if(intL_Bear_TimeBeg>intL_Bear_TimeEnd)
         {
            //intG_Rec_OB_No++;    //licznik prostokątów OB
            //nazwa
            string strL_NoOf_OB_Bar = StringConcatenate(IntegerToString(i),".",IntegerToString(MathRand()));
            string strL_RecName2    = StringConcatenate(strL_StrapName+".Hot_OB.",strL_NoOf_OB_Bar);
      
            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg = Time[intL_Bear_TimeBeg];
            datetime dttL_TimeEnd = Time[intL_Bear_TimeEnd];
      
            //wypełnienie
            intG_WinIdx = WindowFind(strG_NazwaIndi);
            create_Strap(intG_WinIdx,strL_RecName2,clrL_bears,dttL_TimeBeg,dblL_Bear_ValBeg,dttL_TimeEnd,dblL_Bear_ValEnd);                          
          }
      }
   }

   for (int i=0;i<Bars-20;i++)//znajduję piewrszy punkt
   {
      if(DTO_Line[i]  <= indicator_level1)
      {        
         intL_Bull_TimeEnd=i;
         for (int j=i+1;j<Bars-20;j++)// znajduję drugi punkt
         if(DTO_Line[j]>indicator_level1)//arr_SlowLine_HTF_1[j])
         {
            intL_Bull_TimeBeg=j;
            i=j;
            break;
         }
         // - - - rysowanie prostokąta
         if(intL_Bull_TimeBeg>intL_Bull_TimeEnd)
         {  
            //licznik prostokątów OS
            //intG_Rec_OS_No++;

            string strL_NoOf_OB_Bar = StringConcatenate(IntegerToString(i),".",IntegerToString(MathRand()));
            string strL_RecName2    = StringConcatenate(strL_StrapName+".Cold_OS.",strL_NoOf_OB_Bar,"|");

            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg=Time[intL_Bull_TimeBeg];
            datetime dttL_TimeEnd=Time[intL_Bull_TimeEnd];
      
            //wypełnienie
            create_Strap(intG_WinIdx,strL_RecName2,clrL_bulls,dttL_TimeBeg,dblL_Bull_ValBeg,dttL_TimeEnd,dblL_Bull_ValEnd);       
         }
      }
   }
   return true;
}
////+------------------------------------------------------------------+
////+                        Alert Management                          +
////+------------------------------------------------------------------+
bool manage_Alerts()
{
   if(!blnE_Czy_Alerts) return false;
   if(!blnG_Czy_Alerts) return false;


   string strL_Info = Symbol() + " (" + strG_TF_1st + "): " + strG_NazwaIndi + " Says >> ";
   
   if(arr_BullDot[0]>0)    {Alert(strL_Info,"Szykuj się na BUY"); blnG_Czy_Alerts = false;return true;}
   if(arr_BullArrow[0]>0)  {Alert(strL_Info,"BUY");               blnG_Czy_Alerts = false;return true;}
   if(arr_BearDot[0]>0)    {Alert(strL_Info,"Szykuj się na SELL");blnG_Czy_Alerts = false;return true;}
   if(arr_BearArrow[0]>0)  {Alert(strL_Info,"SELL");              blnG_Czy_Alerts = false;return true;}
   
   return true;
}