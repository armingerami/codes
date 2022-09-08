import numpy as np
#a7 = a + 1
def power(p,l):
    if p < 7 and p >= 0:
        if p in l:
            l.remove(p)
        else:
            l.append(p)
    elif p >= 0:
        a = p - 7
        if a < 6:
            if a in l:
                l.remove(a)
            else:
                l.append(a)
            if a+1 in l:
                l.remove(a+1)
            else:
                l.append(a+1)
        elif a == 6:
            if p in l:
                l.remove(0)
            else:
                l.append(0)
            if p in l:
                l.remove(1)
            else:
                l.append(1)
            if p in l:
                l.remove(6)
            else:
                l.append(6)
        else:
            power(a+1,l)
            power(a,l)
            
        
for ii in range(9):
    i = ii + 1
    for j in range(255):
        p = -np.ones(8) #power of position k
        a = np.zeros(8) #coefficient of position k
        q = '{0:08b}'.format(j+1)
        for k in range(8):
            if int(q[-k-1]) == 1:
                p[k] = i*k
            l = []
            power(p[k],l)
            for m in l:
                a[int(m)] = (a[int(m)]+1) % 2
        # print(str(j) + " " + str(q) + str(a) + str(p))
        if all((a+1)%2):
            print("Minimal polynomial " + str(i) + " is " + q)
            break
        
