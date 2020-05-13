UAVrad=50;
numUAVs=6;
UAVpos = [  300 -100
           -300 -100
           300 -300
           000 -400
          -300 300
          -400 -200
          -400  100
          300  300
          200 100
          100 -200
          300 100
          200 -400];

UAVtarget = [ -400 -100
             000 000
             -400 -300
              300  300
              200  000
              -200 200
              300 -300 
              -400 -400
              -200 100
              -400 000 
              200 -400
               300 100];
           
UAVvelocity = zeros(numUAVs,2)
UAVvelocity = analiz_evitar_seguir(UAVrad,numUAVs,UAVpos,UAVtarget)
