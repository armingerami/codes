import numpy as np
        
def find_closest_power_of_2(x,l):
    p = 7
    a = p
    if x > p-1:
        while x > a:
            a *= 2
        if x != a:
            a /= 2    
        powers = [(a/p)+int((x-a)),int((x-a))]
        if powers[0] < p:
            if int(powers[0]) in l:
                l.remove(int(powers[0]))
            else:
                l.append(int(powers[0]))
        else:
            find_closest_power_of_2(powers[0],l)
        if powers[1] < p:
            if int(powers[1]) in l:
                l.remove(int(powers[1]))
            else:
                l.append(int(powers[1]))
        else:
            find_closest_power_of_2(powers[1],l)
    else:
        if x in l:
            l.remove(x)
        else:
            l.append(x)

elements = np.zeros([128,8])
for i in range(128):
    l = []
    find_closest_power_of_2((i+1),l)
    for m in l:
        elements[i][int(m)] = (elements[i][int(m)]+1) % 2 
        
def element_finder(a):
    for i in range(128):
        if all((a - elements[i,:]+1)% 2):
            return(i+1)
    
def div(r1,r2):
    p = 7
    h = [(r1[0] - r2[0])%(2**p-1)]
    
    a = np.zeros(8)
    if r1[1] != -1:
        l = []
        find_closest_power_of_2(r1[1],l)
        for m in l:
            a[int(m)] = (a[int(m)]+1) % 2 
    l = []
    find_closest_power_of_2(h[0]+r2[1],l)
    for m in l:
        a[int(m)] = (a[int(m)]+1) % 2
         
    h.append((element_finder(a) - r2[0])%(2**p-1))
    
    r = -np.ones([len(r1),3])
    for i in range(len(r1)-2):
        r[i,0] = r1[i+2]
        if r2[i+2] != 0: r[i,1] = (h[0]+r2[i+2])%(2**p-1)
        if r2[i+1] != 0: r[i,2] = (h[1]+r2[i+1])%(2**p-1)
    if r2[i+2] != -1: r[i+1,2] = (h[1]+r2[i+2])%(2**p-1)
    
    # print(h)
    print(r)
    
    d = np.zeros(8)
    for i in range(8):
        a = np.zeros(8)
        check = 0
        if r[i,0] != -1:
            check = 1
            l0 = []
            find_closest_power_of_2(r[i,0],l0)
            for m in l0:
                a[int(m)] = (a[int(m)]+1) % 2 
        if r[i,1] != -1:
            check = 1
            l1 = []
            find_closest_power_of_2(r[i,1],l1)
            for m in l1:
                a[int(m)] = (a[int(m)]+1) % 2
        if r[i,2] != -1:
            check = 1
            l2 = []
            find_closest_power_of_2(r[i,2],l2)
            for m in l2:
                a[int(m)] = (a[int(m)]+1) % 2
        if check == 1:
            d[i] = element_finder(a)
    return [h,d]
        
        
        
    
recieved_powers = [126,120,119,117,115,114,112,111,110,109,107,106,105,103,
                   100,98,96,95,94,92,90,82,74]
s = np.zeros([8,8])
for i in range(8):
    for k in recieved_powers:
        l = []
        find_closest_power_of_2(k*(i+1),l)
        for m in l:
            s[i][int(m)] = (s[i][int(m)]+1) % 2

        

r0 = -np.ones(8)
r0[0] = 0
r1 = np.zeros(8)
r1[0] = 114
r1[1] = 120
r1[2] = 22
r1[3] = 85
r1[4] = 120
r1[5] = 74
r1[6] = 123
r1[7] = 61

for i in range(3):
    [h,r2] = div(r0,r1)
    r0 = r1
    for j in range(len(r0)):
        if r0[j] == 0: r0[j] = -1
    r1 = r2
    print([h,r1])
    
    
for i in range(128):
    for j in range(128):
        for k in range(128):
            a = np.zeros(8)  
            l = []
            find_closest_power_of_2(i,l)
            for m in l:
                a[int(m)] = (a[int(m)]+1)%2
            l = []
            find_closest_power_of_2(j,l)
            for m in l:
                a[int(m)] = (a[int(m)]+1)%2
            l = []
            find_closest_power_of_2(k,l)
            for m in l:
                a[int(m)] = (a[int(m)]+1)%2 
                
            b = np.zeros(8)  
            l = []
            find_closest_power_of_2(i+j,l)
            for m in l:
                b[int(m)] = (b[int(m)]+1)%2
            l = []
            find_closest_power_of_2(j+k,l)
            for m in l:
                b[int(m)] = (b[int(m)]+1)%2
            l = []
            find_closest_power_of_2(k+i,l)
            for m in l:
                b[int(m)] = (b[int(m)]+1)%2 
                
            if element_finder(a) == 62 and element_finder(b) == 30 and (i+j+k)%127 == 36:
                print(i,j,k,(i+j+k)%127)