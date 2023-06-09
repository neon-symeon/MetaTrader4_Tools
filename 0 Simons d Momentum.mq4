//+------------------------------------------------------------------+
//|                                               Copyright 2014-2017|
//|                                       http://www.SzymonMarek.com |
//+------------------------------------------------------------------+

//20171027
//kolejny etap zmiany kolorów, tylko kolor główny i do tego kolorszary i nic więcej

//20171022 
//zmiana lekka kolorów, na odcienie zielonego i odcienie czerwonego 

//20170221 przesunąłem strzłkę na ukonstytuowane czyli i>0

//20170117
//oscylatgor zostje przemioanowany z momentum na inertia, inercja, bezwład rynkowy

//20161111 
//pogrubiam strzałki na maxa

//DODAJĘ STRZAŁKI

//20151030
//wróciłem do ceny liczonej z PRICE MEDIAN zamiast PRICE TYPICAL, ponieważ wtedy jest łagodniejszy
//inaczej niż w przypzieszeniu, gdzie jest brana pod uwagę właćnie PRICE TYPICAL, wtedy oscylator jest czulszy
//i na tej zwiększonej czułości tam mi zależy, a tutaj wręcz przeciwnie, bardziej stabilny trend jest monitorowoany

// 20150905
//    zmieniam średnie
// 20150904
//    dodałem parametry w opisie
//20150806 0534
//    na bazie rewelacyjnych doświadczeń na H1 i H4 modyfikuję koncpecję trendu do relacji średnich ema13 i ema52
//    to pociąga korekty we wszystkich oscylatorach opartych o średnnie. wyniki są jeszcze lepsze niż poprzednio

//2015 06 15 g. 11:40   czyszczę i upraszczam, bo to juz fajnie chodzi
//2015 06 01 g. 11:48   //dodaję tween tops and tween bottoms 
//2015 04 19 g. 21:58
//2014 11 20 g. 08:29

#property copyright    "(c) 2014-2017 Szymon Marek"
#property link         "www.SzymonMarek.com"
#property description  "Inercja rynku"
#property strict
#property version      "3.00"

// ustawienia wskaźnika
#property indicator_separate_window

#property indicator_buffers 6

#property indicator_color2 clrGreen
#property indicator_color3 clrRed
#property indicator_color4 clrSilver

#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 1

//strzałki
#property indicator_color5 clrGreen
#property indicator_width5 1
#property indicator_color6 clrRed
#property indicator_width6 1

extern bool blnG_Czy_Arrows = false;

//fixed, not to be changed //na skalach godzinowych potrzebuję 2xszybszy
int intG_FastMA=26;    //;
int intG_SlowMA=104;   //;
int intG_SignalMA=26;  //;

// definicja tablic
double arr_MM[];         //McD
double arr_MM_Lime[];    //jasnozielone słupki 
double arr_MM_Red[];     //czerwone słupki
double arr_MM_Gray[];    //ciemnoczerowne słupki

//double arr_dMACD[];        //pierwsza pochodna z McD

double arr_Arrow_Buy[];    //
double arr_Arrow_Sell[];   //

double dblDotShift;

//zmienne globalne;
string   strG_NazwaIndi;
int      intG_WinIdx;
int      intG_Mnoznik;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
{
//--- Nazwa wskaźnika
   strG_NazwaIndi="Simon's Momentum|";
   if(intG_FastMA!=26 || intG_SlowMA != 104 || intG_SignalMA!=26) strG_NazwaIndi = strG_NazwaIndi +"("+IntegerToString(intG_FastMA)+","+IntegerToString(intG_SlowMA)+","+IntegerToString(intG_SignalMA)+")";
   IndicatorShortName(strG_NazwaIndi);
   intG_WinIdx=WindowFind(strG_NazwaIndi);
   
   IndicatorBuffers(7);
   IndicatorDigits(2);   
   
//--- bufory dla indeksow rysowanych
   SetIndexBuffer(0,arr_MM);              SetIndexStyle(0,DRAW_NONE);      //niewidoczny bazowy
   SetIndexBuffer(1,arr_MM_Lime);         SetIndexStyle(1,DRAW_HISTOGRAM); //histogram jasnozielony
   SetIndexBuffer(2,arr_MM_Red);          SetIndexStyle(2,DRAW_HISTOGRAM); //histogram zielony
   SetIndexBuffer(3,arr_MM_Gray);         SetIndexStyle(3,DRAW_HISTOGRAM); //histogram czerwony
   SetIndexBuffer(4,arr_Arrow_Buy);       SetIndexStyle(4,DRAW_ARROW);   SetIndexArrow(4,233);   SetIndexLabel(4,"Buy");   SetIndexEmptyValue(4,0.0);
   SetIndexBuffer(5,arr_Arrow_Sell);      SetIndexStyle(5,DRAW_ARROW);   SetIndexArrow(5,234);   SetIndexLabel(5,"Sell");  SetIndexEmptyValue(5,0.0);

   //SetIndexBuffer(6,arr_dMACD);
            
//---empty czyli zero
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);   
   SetIndexEmptyValue(5,0.0);
   //SetIndexEmptyValue(6,0.0);


   //powiększacz wartości na dla zwiększenia czytelności oscylatora
   double dblL_ChartMidPrice = iMA(NULL,0,WindowFirstVisibleBar(),0,MODE_SMA,PRICE_CLOSE,1);
   //Alert (Symbol()," MomCalcBase=",dblL_ChartMidPrice);
   if       (dblL_ChartMidPrice<1)      intG_Mnoznik = 100000;
   else if  (dblL_ChartMidPrice<10)     intG_Mnoznik = 10000;
   else if  (dblL_ChartMidPrice<100)    intG_Mnoznik = 1000;
   else if  (dblL_ChartMidPrice<1000)   intG_Mnoznik = 100;
   else if  (dblL_ChartMidPrice<10000)  intG_Mnoznik = 10;
   else                                 intG_Mnoznik = 1;
   
//--- 
   if(!blnG_Czy_Arrows)
   {
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);
   }
   
//--- inicjacja zakończona :)
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Analiza Pędu na bazie średnich 26/52 wygładzonych średnią 13     |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
{
   
   int intL_BTC, intL_BTC_d; 
   
   if       (prev_calculated==0)          //dla pierwszego przelotu
   {
      intL_BTC  = Bars;
      intL_BTC_d = intL_BTC-1;
   } 
   else if  (prev_calculated==rates_total)//przelicza tylko ostatni
   {
      intL_BTC   = 0;
      intL_BTC_d = 1;
   }
   else
   {
      intL_BTC   = rates_total-prev_calculated+1;
      intL_BTC_d = intL_BTC+1;      
   }
   

   //oblicza w sposob klasyczny wartosc MACD - 
   for(int i=0; i<intL_BTC; i++)
      arr_MM[i]=(iMACD(NULL,0,intG_FastMA,intG_SlowMA,intG_SignalMA,PRICE_MEDIAN,MODE_MAIN,i)-
                  iMACD(NULL,0,intG_FastMA,intG_SlowMA,intG_SignalMA,PRICE_MEDIAN,MODE_SIGNAL,i))*intG_Mnoznik;



   //oblicza roznice miedzy kolejnymi slupkami, czyli dMACD i dopasowuje kolor wskaźnika
   for(int i=0; i<intL_BTC_d; i++)
   {
      double dblL_dMACD=arr_MM[i]-arr_MM[i+1];//oblicza i zapisuje wart pierw poch

      arr_MM_Lime[i]  = 0;
      arr_MM_Red[i]   = 0;
      arr_MM_Gray[i]  = 0;

      if       (arr_MM[i]>0)
      {      
         if(dblL_dMACD>0)     arr_MM_Lime[i] = arr_MM[i];
         else                 arr_MM_Gray[i] = arr_MM[i];
      }
      else
      {      
         if(dblL_dMACD<0)     arr_MM_Red[i]   = arr_MM[i];
         else                 arr_MM_Gray[i]  = arr_MM[i];
      }

      if(i>0)
      {
         if(arr_MM[i]>0 && arr_MM[i+1]<0)
         {
            arr_Arrow_Buy[i] = -MaxSpreadOnScreen()/5;
         }
         else
         {
            arr_Arrow_Buy[i] = 0;
         } 
         
         if(arr_MM[i]<0 && arr_MM[i+1]>0)
         {
            arr_Arrow_Sell[i] = MaxSpreadOnScreen()/5;
         }
         else
         {
            arr_Arrow_Sell[i] = 0;
         }         
      }
   }
   
   
            
return(rates_total);
}
//+------------------------------------------------------------------+


double MaxSpreadOnScreen()
{
   
   double dblL_Max_MACD=-100;
   
   for(int i=0;i<233;i++)
   if(MathAbs(arr_MM[i])>dblL_Max_MACD) 
      dblL_Max_MACD = arr_MM[i];  

   return dblL_Max_MACD;
}
