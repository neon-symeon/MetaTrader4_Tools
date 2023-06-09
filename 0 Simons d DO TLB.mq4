//+------------------------------------------------------------------+
//|                 Simon's Dynamic Oscillator Triple Look Back.mq4  |
//|                                                     Szymon Marek |
//|                                       http://www.SzymonMarek.com |
//+------------------------------------------------------------------+

//20170919 triple time frame
#property copyright "(c) Szymon Marek 2014-2018"
#property link      "www.SzymonMarek.com"
#property version   "1.10"
#property description "Simon's Dynamic Oscylator Triple Look Back"
#property description " "
#property description "Szczegóły opisu ustawień w oscylatorze bazowym Simons DO"
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
#property indicator_color1 clrAqua
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

#property indicator_color2 clrMagenta
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

#property indicator_color3 clrLime
#property indicator_style3 STYLE_DOT
#property indicator_width3 1

#property indicator_color4 clrRed
#property indicator_style4 STYLE_DOT
#property indicator_width4 1

#property indicator_color5 clrAqua
#property indicator_width5 1

#property indicator_color6 clrMagenta
#property indicator_width6 1

#property indicator_color7 clrLime
#property indicator_width7 2
#property indicator_color8 clrBrown
#property indicator_width8 2
//+------------------------------------------------------------------+
#property indicator_buffers 8
double arr_FastLine[];
double arr_SlowLine[];
double arr_FastLine_DLB[];
double arr_SlowLine_DLB[];
double arr_FastLine_TLB[];
double arr_SlowLine_TLB[];
double arr_BullArrow[];
double arr_BearArrow[];
double arr_BullArrow_DLB[];
double arr_BearArrow_DLB[];
//+------------------------------------------------------------------+
//zmienne zewnętrzne
//+------------------------------------------------------------------+
extern string           s0="--- Pierwsza Para ---";               //---
extern bool                blnE_Czy_P1             = true;        //Czy Linie Pierwszego Oscylatora
extern bool                blnE_Czy_P1_Cross       = true;        //Czy Znaczniki Przecięć
extern ENUMS_DO_SET        enmE_DO_Set_TTF         = set_2;       //Parametr DO
extern string           s1="--- Druga Para ---";                  //---
extern bool                blnE_Czy_P2             = true;       //Czy Linie Drugiego Oscylatora
extern bool                blnE_Czy_P2_Cross       = false;       //Czy Znaczniki Przecięć
extern ENUMS_DO_SET        enmE_DO_Set_TTF_DLB     = set_1;       //Parametr DO
extern string           s2="--- Trzecia Para czyli pasek ---";    //---
extern bool                blnE_Czy_P3_Strap       = true;        //Czy Pasek OBOS
extern ENUMS_DO_SET        enmE_DO_Set_TTF_TLB     = set_3;       //Parametr DO
extern ENUMS_DO_Line       enmE_DO_Line            = line_fast;   //Która Linia Ma Wejść Do Strefy
extern string           s3="--- Kolory Ramek OB/OS ---";    //---
extern color               clrE_Bull_Fill  = clrLime;//clrAqua;//clrGreen;//clrTeal;//clrGreenYellow; - dla zgodności z DO.MTF
extern color               clrE_Bear_Fill  = clrRed; //clrMagenta;//clrRed;//clrBrown;//clrOrange;
extern string           s4 = "--- Czy Wyświetlać Odczyty ---";    //---
extern bool                blnE_Display_DO_Readings    = true;
//+------------------------------------------------------------------+
//globalne zmienne
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES   enmG_TTF = Period();
string            strG_TTF = translate_TF(enmG_TTF);
ENUMS_DO_SET      enmG_DO_Set_1st, enmG_DO_Set_2nd, enmG_DO_Set_3rd; //DO settings
int               intG_WinIdx;                  //indeks okna wskaźnika
string            strG_NazwaIndi;               //nazwa indykatora
int               intG_Thick = 13;              //grubość paska
int               intG_Rec_OS_No=0;             //do nazw i zliczania wygenerowanych kwadratów OS
int               intG_Rec_OB_No=0;             //do nazw i zliczania wygenerowanych kwadratów OB
string strG_Readings_TTF_1 = "DO TLB Readings 1";                    //DO readings
string strG_Readings_TTF_2 = "DO TLB Readings 2";
string strG_Readings_TTF_3 = "DO TLB Readings 3";
string strG_Shade_Readings = "DO TLB Shade";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- dokładność wyświetleń
   IndicatorDigits(1);
   //--- ogarnia ustawienia DO
   if(enmE_DO_Set_TTF     == set_Auto)    enmG_DO_Set_1st = set_1;
   else                                   enmG_DO_Set_1st = enmE_DO_Set_TTF;
   if(enmE_DO_Set_TTF_DLB == set_Auto)    enmG_DO_Set_2nd = convert_DO_Auto_Settings(enmG_DO_Set_1st);
   else                                   enmG_DO_Set_2nd = enmE_DO_Set_TTF_DLB;
   if(enmE_DO_Set_TTF_TLB == set_Auto)    enmG_DO_Set_3rd = convert_DO_Auto_Settings(MathMax(enmG_DO_Set_1st,enmG_DO_Set_2nd));
   else                                   enmG_DO_Set_3rd = enmE_DO_Set_TTF_TLB;
   //--- nazwa oscylatora, gdy wszystko już ustawione
   strG_NazwaIndi = "Simon's Triple Look Back DO|";
   if(blnE_Czy_P1)                                          strG_NazwaIndi = strG_NazwaIndi + translate_DO_settings(enmG_DO_Set_1st);
   if(blnE_Czy_P1 && blnE_Czy_P2)                           strG_NazwaIndi = strG_NazwaIndi + ";";
   if(blnE_Czy_P2)                                          strG_NazwaIndi = strG_NazwaIndi + translate_DO_settings(enmG_DO_Set_2nd);
   if( (blnE_Czy_P1 || blnE_Czy_P2) && blnE_Czy_P3_Strap)   strG_NazwaIndi = strG_NazwaIndi + ";";
   if(blnE_Czy_P3_Strap)                                    strG_NazwaIndi = strG_NazwaIndi + translate_DO_settings(enmG_DO_Set_3rd);
   strG_NazwaIndi = strG_NazwaIndi + "|";
   IndicatorShortName(strG_NazwaIndi); 
   //--- mapowanie
   IndicatorBuffers(10);
   SetIndexBuffer(0,arr_FastLine);        SetIndexStyle(0,DRAW_LINE);   SetIndexEmptyValue(0,0.0); SetIndexLabel(0,"Fast Line");
   SetIndexBuffer(1,arr_SlowLine);        SetIndexStyle(1,DRAW_LINE);   SetIndexEmptyValue(1,0.0); SetIndexLabel(1,"Slow Line");
   SetIndexBuffer(2,arr_FastLine_DLB);    SetIndexStyle(2,DRAW_LINE);   SetIndexEmptyValue(2,0.0); SetIndexLabel(2,"DLB: Fast Line");
   SetIndexBuffer(3,arr_SlowLine_DLB);    SetIndexStyle(3,DRAW_LINE);   SetIndexEmptyValue(3,0.0); SetIndexLabel(3,"DLB: Slow Line");
   SetIndexBuffer(4,arr_BullArrow);       SetIndexStyle(4,DRAW_ARROW);  SetIndexEmptyValue(4,0.0); SetIndexArrow(4,119);     
   SetIndexBuffer(5,arr_BearArrow);       SetIndexStyle(5,DRAW_ARROW);  SetIndexEmptyValue(5,0.0); SetIndexArrow(5,119);     
   SetIndexBuffer(6,arr_BullArrow_DLB);   SetIndexStyle(6,DRAW_ARROW);  SetIndexEmptyValue(6,0.0); SetIndexArrow(6,159);     //217 //175 //108 //161
   SetIndexBuffer(7,arr_BearArrow_DLB);   SetIndexStyle(7,DRAW_ARROW);  SetIndexEmptyValue(7,0.0); SetIndexArrow(7,159);     //218
   SetIndexBuffer(8,arr_FastLine_TLB);
   SetIndexBuffer(9,arr_SlowLine_TLB);
   //wykluczenia
   if(!blnE_Czy_P1)
   {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);
   }
   if(!blnE_Czy_P2)
   {
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexStyle(6,DRAW_NONE);
      SetIndexStyle(7,DRAW_NONE);      
   }
   if(!blnE_Czy_P1_Cross)
   {
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);      
   }
   if(!blnE_Czy_P2_Cross)
   {
      SetIndexStyle(6,DRAW_NONE);
      SetIndexStyle(7,DRAW_NONE);      
   }
   intG_WinIdx = WindowFind(strG_NazwaIndi);
   if(!blnE_Czy_P3_Strap) delete_All_Straps_and_Boxes(intG_WinIdx);
   //readings
   if(blnE_Display_DO_Readings)show_Readings();else delete_Readings();
//--- 
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
   int                                       intL_BTC = rates_total-prev_calculated+1;
   if       (prev_calculated==0)             intL_BTC = Bars - calc_DO_Begin(enmG_DO_Set_1st,enmG_DO_Set_2nd,enmG_DO_Set_3rd);
   else if  (prev_calculated==rates_total)   intL_BTC = 0;
   //Lines TTF
   for (int i=0;i<=intL_BTC;i++)
   {
      if(blnE_Czy_P1)
      {
         arr_FastLine[i]= calc_DO_single_line(0,enmG_DO_Set_1st,line_fast,i);
         arr_SlowLine[i]= calc_DO_single_line(0,enmG_DO_Set_1st,line_slow,i);
      }
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
   //Crosses - Arrows
   for (int i=1;i<=intL_BTC;i++)
   { 
      arr_BullArrow[i]=0;        arr_BearArrow[i]=0;      
      if(arr_FastLine[i]>arr_SlowLine[i] && arr_FastLine[i+1]<arr_SlowLine[i+1]) arr_BullArrow[i] = arr_FastLine[i];
      if(arr_FastLine[i]<arr_SlowLine[i] && arr_FastLine[i+1]>arr_SlowLine[i+1]) arr_BearArrow[i] = arr_SlowLine[i];
      
      arr_BullArrow_DLB[i] = 0;  arr_BearArrow_DLB[i] = 0;         
      if(arr_FastLine_DLB[i]>arr_SlowLine_DLB[i] && arr_FastLine_DLB[i+1]<arr_SlowLine_DLB[i+1]) arr_BullArrow_DLB[i] = arr_FastLine_DLB[i];
      if(arr_FastLine_DLB[i]<arr_SlowLine_DLB[i] && arr_FastLine_DLB[i+1]>arr_SlowLine_DLB[i+1]) arr_BearArrow_DLB[i] = arr_SlowLine_DLB[i];
   }
   //strefy draw_OBOS_Straps_and_Boxes
   //jest pomysł na przerobienie tego żeby była łączna suma, czyli i to i to w strefie, wtedy byłąby żyleta
   if(blnE_Czy_P3_Strap)
   if(prev_calculated!=rates_total)  
   {
      if       (enmE_DO_Line == line_slow)   draw_OBOS_Straps_and_Boxes(arr_SlowLine_TLB);
      else if  (enmE_DO_Line == line_fast)   draw_OBOS_Straps_and_Boxes(arr_FastLine_TLB);
   }
   //ogrania odczyty DO
   manage_Readings();
   //
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
   int intL_H = 32;                             //wysokość cienia
   int intL_PK = 20; //prawa korekta - dla zmiany wyswietlania z lewej na prawa min to 166, a w drugą stronę 344
   
   color clrL_Shade = ChartGetInteger(ChartID(),CHART_COLOR_BACKGROUND); //cień w kolorze tła
   //kasowanie poprzednich wynków
   delete_Readings();
   //tworzenie nowych
   create_RectLabel (ChartID(),strG_Shade_Readings,intG_WinIdx,intL_X+intL_PK,intL_Y,144,intL_H,clrL_Shade,1,CORNER_LEFT_UPPER);
   intL_Y = intL_Y + 4; //leciutki margines
                                 
   if(blnE_Czy_P1)                  create_Label(ChartID(),strG_Readings_TTF_1,  intG_WinIdx,intL_X+intL_PK+4,intL_Y+13*1, CORNER_LEFT_UPPER,"R1","Arial",8);
                                    create_Label(ChartID(),strG_Readings_TTF_2,  intG_WinIdx,intL_X+intL_PK+4,intL_Y+13*2, CORNER_LEFT_UPPER,"R2","Arial",8);
   //if(blnE_Czy_P3_Strap)            create_Label(ChartID(),strG_Readings_TTF_3,  intG_WinIdx,intL_X+166,intL_Y+13*3, CORNER_RIGHT_UPPER,"R3","Arial",8);
   
   return true;
}
//+------------------------------------------------------------------+
bool manage_Readings()
{
   //abstrakt 20180905
   if(!blnE_Display_DO_Readings) return false;

   calc_Readings(0);   
   calc_Readings(1);   
   //calc_Readings(2);   

   int intL_StringLen = calculate_Shadow_Len(strG_Readings_TTF_1,strG_Readings_TTF_2,strG_Readings_TTF_3);
   ObjectSetInteger(ChartID(),strG_Shade_Readings,OBJPROP_XSIZE,intL_StringLen);
   
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
      strL_TF = strG_TTF;
   }
   if(head_level == 1)
   {
      enmL_TimeFrame = 0;  enmL_DO_Set = enmG_DO_Set_2nd;
      strL_TF = strG_TTF;
   }
   if(head_level == 2)
   {
      enmL_TimeFrame = 0;  enmL_DO_Set = enmG_DO_Set_3rd;
      strL_TF = strG_TTF;
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
   //if(head_level == 2)
   //{
   //   ObjectSetString(ChartID(), strG_Readings_TTF_3, OBJPROP_TEXT, strL_Text);
   //   ObjectSetInteger(ChartID(),strG_Readings_TTF_3, OBJPROP_COLOR,clrL_DO_color);
   //   ObjectSetString(ChartID(), strG_Readings_TTF_3, OBJPROP_FONT, strL_DO_font);
   //}
   return true;
}
//+------------------------------------------------------------------+
bool delete_Readings()
{
   if(ObjectFind(ChartID(),strG_Shade_Readings) >-1)  ObjectDelete(ChartID(),strG_Shade_Readings);
   if(ObjectFind(ChartID(),strG_Readings_TTF_1) >-1)  ObjectDelete(ChartID(),strG_Readings_TTF_1);
   if(ObjectFind(ChartID(),strG_Readings_TTF_2) >-1)  ObjectDelete(ChartID(),strG_Readings_TTF_2);
   if(ObjectFind(ChartID(),strG_Readings_TTF_3) >-1)  ObjectDelete(ChartID(),strG_Readings_TTF_3);

   return true;
}
//+------------------------------------------------------------------+
bool draw_OBOS_Straps_and_Boxes(double &DTO_Line[])
//20150913 zacząłem, a teraz (20150914) kontynuuję
//prostokąty OB/OS
{  
   intG_WinIdx=WindowFind(strG_NazwaIndi); // odświeża które okno strapować
   delete_All_Straps_and_Boxes(intG_WinIdx);
   
   //ust koloru pasków
   color clrL_Bull_Fill  = clrE_Bull_Fill;//clrAqua;//clrGreen;//clrTeal;//clrGreenYellow; - dla zgodności z DO.MTF
   color clrL_Bear_Fill  = clrE_Bear_Fill;//clrMagenta;//clrRed;//clrBrown;//clrOrange;
   
   int      intL_TimeEnd = 0;
   int      intL_TimeBeg = 0;
   double   dblL_ValBeg  = 100- (20-intG_Thick)/2;
   double   dblL_ValEnd  = 80 + (20-intG_Thick)/2;
   
   int      intL_Bull_TimeEnd = 0;
   int      intL_Bull_TimeBeg = 0;
   double   dblL_Bull_ValBeg  = 0 + (20-intG_Thick)/2;
   double   dblL_Bull_ValEnd  = 20- (20-intG_Thick)/2;
   
   for (int i=0;i<Bars-20;i++)//znajduję piewrszy punkt
   {
      if(DTO_Line[i] >= indicator_level3)       //znajdowanie pierwszych parametrów
      {          
         intL_TimeEnd=i;
         for (int j=i+1;j<Bars-20;j++)
         if(DTO_Line[j]<=indicator_level3)      // znajdowanie drugich punktów
         {
            intL_TimeBeg=j;
            i=j;
            break;
         }
         
         // - - - rysowanie prostokąta
         if(intL_TimeBeg>intL_TimeEnd)
         {
            
            intG_Rec_OB_No++;    //licznik prostokątów OB
            //nazwa
            string strL_NoOf_OB_Bar = StringConcatenate(IntegerToString(intG_Rec_OB_No)," ",IntegerToString(MathRand()));
            string strL_RecName2    = StringConcatenate("RecOB",strL_NoOf_OB_Bar,"|");
      
            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg=Time[intL_TimeBeg];
            datetime dttL_TimeEnd=Time[intL_TimeEnd];
      
            //wypełnienie
            create_Strap(intG_WinIdx, strL_RecName2,clrL_Bear_Fill,dttL_TimeBeg,dblL_ValBeg,dttL_TimeEnd,dblL_ValEnd);                          
          }
      }
   }

   for (int i=0;i<Bars-20;i++)//znajduję piewrszy punkt
   {
      if(DTO_Line[i]  <= indicator_level1)
      {        
         intL_Bull_TimeEnd=i;
         for (int j=i+1;j<Bars-20;j++)// znajduję drugi punkt
         if(DTO_Line[j]>indicator_level1)//arr_SlowLine_HTF[j])
         {
            intL_Bull_TimeBeg=j;
            i=j;
            break;
         }
      // - - - rysowanie prostokąta
         if(intL_Bull_TimeBeg>intL_Bull_TimeEnd)
         {  
            //licznik prostokątów OS
            intG_Rec_OS_No++;

            string strL_NoOf_OS_Bar=StringConcatenate(IntegerToString(intG_Rec_OS_No)," ",IntegerToString(MathRand()));
            string strL_RecName=StringConcatenate("RecOS ",strL_NoOf_OS_Bar);
            string strL_RecName2=StringConcatenate(strL_RecName,"|");   
      
            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg=Time[intL_Bull_TimeBeg];
            datetime dttL_TimeEnd=Time[intL_Bull_TimeEnd];
      
            //wypełnienie
            create_Strap(intG_WinIdx,strL_RecName2,clrL_Bull_Fill,dttL_TimeBeg,dblL_Bull_ValBeg,dttL_TimeEnd,dblL_Bull_ValEnd);       
         }
      }
   }
   return true;
}