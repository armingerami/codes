import numpy as np
import matplotlib.pyplot as plt
    
# constants
call_drops_based_on_EIRP = np.zeros([6,2])
for eirp in np.linspace(57, 57, 1): # set to np.linspace(57, 47, 6) for Q2
    hom = 3 # or 7 or 0
    total_simulation_time_in_hours = 4
    number_of_users = 150
    call_rate = 2/(60*60) #call rate per user per second
    avrg_call_lngth = 120
    user_speed = 15
    dstnc = 5000
    h_bstn = 50
    y_bstn1 = -20
    y_bstn2 = 500
    n_chnls = 15
    f = 900
    thrshld = -104
    h_mbl = 1
    h_bldng = 60
    shadowing = np.random.normal(0,2,[int(dstnc/10)+1, 2])
    
    # functions
    def location_calculator(x, t):
        if x**2 + y_bstn1**2 < (dstnc-x)**2 + y_bstn2**2:
            direction = 1
        else:
            direction = -1
        return x + direction*user_speed*np.arange(1, t+1)
    
    def rsl_calculator(x, k):
        x = min(dstnc, x)
        if k == 1:
            d = np.sqrt(x**2 + y_bstn1**2)/1000
            oh = 69.55 + 26.16*np.log10(f) - 13.82*np.log10(h_bstn) + (44.9 - 6.55*np.log10(h_bstn))*np.log10(d) \
                - (1.1*np.log10(f) - 0.7)*h_mbl + 1.56*np.log10(f) - 0.8
            fading = 20*np.log10(np.sort(np.random.rayleigh(1,10))[1]) #choosing the second worst scenario
            return eirp - oh + shadowing[int(np.floor(x/10))][0] + fading
        
        if k == 2:
            d = np.sqrt((dstnc - x)**2 + y_bstn2**2)/1000
            oh = 69.55 + 26.16*np.log10(f) - 13.82*np.log10(h_bstn) + (44.9 - 6.55*np.log10(h_bstn))*np.log10(d) \
                - (1.1*np.log10(f) - 0.7)*h_mbl + 1.56*np.log10(f) - 0.8
            fading = 20*np.log10(np.sort(np.random.rayleigh(1,10))[1]) #choosing the second worst scenario
            if (dstnc - x) > 1389 or (dstnc - x) < 1002: #out of this region, building doesn't affect RSL
                ske = 0
            else:
                y = y_bstn1*(x-1000)/x #distance of base of where line of sight hits building from the road
                d1 = np.sqrt((x-1000)**2 + y**2) #distance from mobile to base of where line of sight hits building
                d2 = np.sqrt(1000**2 + (500 - y)**2) #distance from bstn to base of where line of sight hits building
                h = h_bldng - (h_bstn - h_mbl)*d1/(d1+d2) - h_mbl
                l = 300/f
                v = h*np.sqrt((2*d1 + 2*d2)/(l*d1*d2))
                if v >= 0 and v < 1:
                    ske = 20*np.log10(0.5*np.exp(-0.95*v))
                elif v >= 1 and v < 2.4:
                    ske = 20*np.log10(0.4 - np.sqrt(0.1184 - (0.38 - 0.1*v)**2))
                elif v >= 2.4:
                    ske = 20*np.log10(0.225/v)
            return eirp - oh + shadowing[int(np.floor(x/10))][1] + fading + ske
    
    def switch(x): #switch's 1 with 2 and 2 with 1; usefull when we want to do handoff
        if x == 1: return 2
        if x == 2: return 1
    
    # observables
    number_of_total_call_requests = 0
    number_of_succ_call_connection = np.zeros(2)
    number_of_blocked_call_req_due_rsl = np.zeros(2)
    number_of_blocked_call_req_due_capacity = np.zeros(2)
    
    number_of_succ_call_end = np.zeros(2)
    number_of_call_drops = np.zeros(2)
    
    number_of_ho_attempts = np.zeros(2)
    number_of_ho_succ = np.zeros(2)
    number_of_ho_failed = np.zeros(2)
    
    number_of_channels_in_use = 0
    
    # simulation
    simulation_time = int(total_simulation_time_in_hours*60*60) #simulation time in seconds
    bstn_available_channels = [n_chnls, n_chnls]
    active_call = np.zeros([simulation_time, number_of_users])
    user_location = np.zeros([simulation_time, number_of_users])
    user_bstn = np.zeros(number_of_users, dtype = int) #sets to 1 if user is connected to bstn1 and 2 if conneced to bstn2 and 0 if not connected
    s_i = np.zeros([int(np.floor(dstnc/100)+1), number_of_users,2]) #this is S/I based on position
    
    counter = 1
    for i in range(simulation_time):
        number_of_channels_in_use = 2*n_chnls - bstn_available_channels[0] - bstn_available_channels[1]
        if np.floor(i/3600) == counter: # this is for giving a report for every hour
            print("Report for the hour " + str(counter) + ":")
            print("Number of total call requests = " + str(number_of_total_call_requests))
            print("Number of succesful call connections for bstn1= " + str(number_of_succ_call_connection[0]))
            print("Number of succesful call connections for bstn2= " + str(number_of_succ_call_connection[1]))
            print("Number of blocked call requests due to low RSL for bstn1 = " + str(number_of_blocked_call_req_due_rsl[0]))
            print("Number of blocked call requests due to low RSL for bstn2 = " + str(number_of_blocked_call_req_due_rsl[1]))
            print("Number of blocked call requests due to low capacity for bstn1 = " + str(number_of_blocked_call_req_due_capacity[0]))
            print("Number of blocked call requests due to low capacity for bstn2 = " + str(number_of_blocked_call_req_due_capacity[1]))
            print("")
            print("Number of succesful call terminations for bstn1 = " + str(number_of_succ_call_end[0]))
            print("Number of succesful call terminations for bstn2 = " + str(number_of_succ_call_end[1]))
            print("Number of call drops for bstn1 = " + str(number_of_call_drops[0]))
            print("Number of call drops for bstn2 = " + str(number_of_call_drops[1]))
            print("")
            print("Number of handoff attempts for bstn1 = " + str(number_of_ho_attempts[0]))
            print("Number of handoff attempts for bstn2 = " + str(number_of_ho_attempts[1]))
            print("Number of successful handoffs for bstn1 = " + str(number_of_ho_succ[0]))
            print("Number of successful handoffs for bstn2 = " + str(number_of_ho_succ[1]))
            print("Number of failed handoffs for bstn1 = " + str(number_of_ho_failed[0]))
            print("Number of failed handoffs for bstn2 = " + str(number_of_ho_failed[1]))
            print("")
            print("Number of channels in use = " + str(number_of_channels_in_use))
            print("")
            counter += 1
    
        for j in range(number_of_users):
            if active_call[i, j] == 1:
                rsl_server = rsl_calculator(user_location[i,j], user_bstn[j])
                rsl_other = rsl_calculator(user_location[i,j], switch(user_bstn[j]))
                
                if rsl_server >= thrshld:
                    s_i[int(np.floor(user_location[i,j]/100))][j][user_bstn[j]-1] = rsl_server - rsl_other #storing the S/I for the serving bstn based on position
                    s_i[int(np.floor(user_location[i,j]/100))][j][switch(user_bstn[j])-1] = rsl_other - rsl_server ##storing the S/I for the other bstn based on position
                
                if user_location[i, j] < 0 or user_location[i, j] > 5000:
                    number_of_succ_call_end[user_bstn[j]-1] += 1 #if user exits the road call ends successfuly
                    active_call[i:, j] = 0
                    bstn_available_channels[user_bstn[j]-1] += 1
                    continue #we put continue because only one of these actions can happen for an active call
                
                elif rsl_server < thrshld:
                    active_call[i:, j] = 0
                    number_of_call_drops[user_bstn[j]-1] += 1 #call gets dropped due to low RSL
                    bstn_available_channels[user_bstn[j]-1] += 1
                    continue
                
                elif i == simulation_time - 1:
                    number_of_succ_call_end[user_bstn[j]-1] += 1 #if simulation ends while call is active call ends successfuly
                    continue
                
                elif active_call[i+1, j] == 0:
                    number_of_succ_call_end[user_bstn[j]-1] += 1 #if call duration runs out call ends successfuly
                    bstn_available_channels[user_bstn[j]-1] += 1
                    continue
        
                elif rsl_other - rsl_server > hom:
                    number_of_ho_attempts[user_bstn[j]-1] += 1 #condition for a hand off is met
                    if bstn_available_channels[switch(user_bstn[j]) - 1] > 0:
                        number_of_ho_succ[user_bstn[j]-1] += 1 #hand off is successful
                        # number_of_succ_call_end[user_bstn[j]-1] += 1 #call for the bstn that initiated handoff ended successfully
                        bstn_available_channels[user_bstn[j]-1] += 1
                        user_bstn[j] = switch(user_bstn[j])
                        bstn_available_channels[user_bstn[j]-1] -= 1
                        continue
                    else:
                        number_of_ho_failed[user_bstn[j]-1] += 1 #hand off failed due to capacity
                        continue
                     
            if active_call[i, j] == 0:
                if np.random.rand(1) <= call_rate:
                    make_connection = 1 #a variable to check if connection will be made
                    number_of_total_call_requests += 1
                    user_location[i, j] = np.floor(np.random.rand(1)*dstnc)
                    rsl_1 = rsl_calculator(user_location[i,j], 1)
                    rsl_2 = rsl_calculator(user_location[i,j], 2)
                    if rsl_1 > rsl_2:
                        if rsl_1 < thrshld:
                            number_of_blocked_call_req_due_rsl[0] += 1 #dropped call due to low RSL for bstn1
                            make_connection = 0
                        elif bstn_available_channels[0] > 0:
                            user_bstn[j] = 1
                            bstn_available_channels[user_bstn[j]-1] -= 1
                            number_of_succ_call_connection[user_bstn[j]-1] += 1 #succesful connection for bstn1
                        elif rsl_2 >= thrshld and bstn_available_channels[1] > 0:
                            user_bstn[j] = 2
                            bstn_available_channels[user_bstn[j]-1] -= 1
                            number_of_succ_call_connection[user_bstn[j]-1] += 1 #succesful connection for bstn2
                        else:
                            number_of_blocked_call_req_due_capacity[0] += 1 #dropped call due to capacity for bstn1
                            make_connection = 0
                    
                    else:
                        if rsl_2 < thrshld:
                            number_of_blocked_call_req_due_rsl[1] += 1 #dropped call due to low RSL for bstn2
                            make_connection = 0
                        elif bstn_available_channels[1] > 0:
                            user_bstn[j] = 2
                            bstn_available_channels[user_bstn[j]-1] -= 1
                            number_of_succ_call_connection[user_bstn[j]-1] += 1 #succesful connection for bstn2
                        elif rsl_1 >= thrshld and bstn_available_channels[0] > 0:
                            user_bstn[j] = 1
                            bstn_available_channels[user_bstn[j]-1] -= 1
                            number_of_succ_call_connection[user_bstn[j]-1] += 1 #succesful connection for bstn1
                        else:
                            number_of_blocked_call_req_due_capacity[1] += 1 #dropped call due to capacity for bstn2
                            make_connection = 0
                    
                    
                    if make_connection == 1: # now that we know connection is made, we'll calculate call duration and user location for the call duration
                        # print(user_bstn[j])
                        call_duration = int(np.floor(np.random.exponential(avrg_call_lngth)))
                        call_duration = min(call_duration, simulation_time - i - 1) # making sure the call will not exceed our simulation time
                        active_call[i+1:i+call_duration+1, j] = 1 # the call duration is at least 1 second
                        user_location[i+1:i+call_duration+1, j] = location_calculator(user_location[i, j], call_duration) #calculating user location for the call duration
                        

    # bar chart of S/I based on posiiton
    green = np.zeros([int(np.floor(dstnc/100)),2])
    magenta = np.zeros([int(np.floor(dstnc/100)),2])
    red = np.zeros([int(np.floor(dstnc/100)),2])
    for i in range(int(dstnc/100)):
        for j in range(number_of_users):
            for k in range(2):
                if s_i[i,j,k] >= 10:
                    green[i, k] += 1
                elif s_i[i,j,k] >= 5:
                    magenta[i, k] += 1
                else:
                    red[i, k] += 1
                    
    for k in range(2):
        fig = plt.figure()
        ax = fig.add_axes([0,0,1,1])
        positions = np.arange(50)
        ax.bar(positions - 0.25,green[:,k], color = 'g', width = 0.5)
        ax.bar(positions,magenta[:,k], color = 'm', width = 0.5)
        ax.bar(positions + 0.25,red[:,k], color = 'r', width = 0.5)
        plt.title("Number of green, magenta and red points for bstn" + str(k+1) + " per 100m")
        plt.legend(['Total number of green points','Total number of magenta points','Total number of red points'])
        plt.show()
        
    
    
    # Q1
    print("")
    print("")
    print("Q1")
    print("for EIRP = " + str(eirp)+ " and HOM = " + str(hom))
    print("Number of total call requests = " + str(number_of_total_call_requests))
    print("Number of succesful call connections for bstn1= " + str(number_of_succ_call_connection[0]))
    print("Number of succesful call connections for bstn2= " + str(number_of_succ_call_connection[1]))
    print("Number of blocked call requests due to low RSL for bstn1 = " + str(number_of_blocked_call_req_due_rsl[0]))
    print("Number of blocked call requests due to low RSL for bstn2 = " + str(number_of_blocked_call_req_due_rsl[1]))
    print("Number of blocked call requests due to low capacity for bstn1 = " + str(number_of_blocked_call_req_due_capacity[0]))
    print("Number of blocked call requests due to low capacity for bstn2 = " + str(number_of_blocked_call_req_due_capacity[1]))
    print("percentage of succesful calls = " + str(100*(number_of_succ_call_connection[0] + number_of_succ_call_connection[1])/number_of_total_call_requests))
    print("percentage of blocked calls due to low RSL = " + str(100*(number_of_blocked_call_req_due_rsl[0] + number_of_blocked_call_req_due_rsl[1])/number_of_total_call_requests))
    print("percentage of blocked calls due to low capacity = " + str(100*(number_of_blocked_call_req_due_capacity[0] + number_of_blocked_call_req_due_capacity[1])/number_of_total_call_requests))
    print("")
    
    print("Number of succesful call terminations for bstn1 = " + str(number_of_succ_call_end[0]))
    print("Number of succesful call terminations for bstn2 = " + str(number_of_succ_call_end[1]))
    print("Number of call drops for bstn1 = " + str(number_of_call_drops[0]))
    print("Number of call drops for bstn2 = " + str(number_of_call_drops[1]))
    print("percentage of calls dropped due to low RSL = " + str(100*(number_of_call_drops[0] + number_of_call_drops[1])/(number_of_succ_call_end[0] + number_of_succ_call_end[1] + number_of_call_drops[0] + number_of_call_drops[1])))
    print("")
    
    print("Number of handoff attempts for bstn1 = " + str(number_of_ho_attempts[0]))
    print("Number of handoff attempts for bstn2 = " + str(number_of_ho_attempts[1]))
    print("Number of successful handoffs for bstn1 = " + str(number_of_ho_succ[0]))
    print("Number of successful handoffs for bstn2 = " + str(number_of_ho_succ[1]))
    print("Number of failed handoffs for bstn1 = " + str(number_of_ho_failed[0]))
    print("Number of failed handoffs for bstn2 = " + str(number_of_ho_failed[1]))
    print("percentage of failed handofss = " + str(100*(number_of_ho_failed[0] + number_of_ho_failed[1])/(number_of_ho_attempts[0] + number_of_ho_attempts[1])))
    
    # Q2
#     call_drops_based_on_EIRP[int((57 - eirp)/2),0] = number_of_call_drops[0]
#     call_drops_based_on_EIRP[int((57 - eirp)/2),1] = number_of_call_drops[1]
# print("Q2")
# plt.figure()
# plt.xlabel("EIRP")
# plt.ylabel("number of call drops")
# plt.plot(np.linspace(57,47,6), call_drops_based_on_EIRP[:,0],np.linspace(57,47,6), call_drops_based_on_EIRP[:,1])
# plt.legend(["bstn1", "bstn2"])
    
#Q3
# print("")
# print("")
# print("Q3")
# print("for EIRP = " + str(eirp) + " and HOM = " + str(hom))
# print("Number of handoff attempts for bstn1 = " + str(number_of_ho_attempts[0]))
# print("Number of handoff attempts for bstn2 = " + str(number_of_ho_attempts[1]))
# print("Number of successful handoffs for bstn1 = " + str(number_of_ho_succ[0]))
# print("Number of successful handoffs for bstn2 = " + str(number_of_ho_succ[1]))
# print("Number of failed handoffs for bstn1 = " + str(number_of_ho_failed[0]))
# print("Number of failed handoffs for bstn2 = " + str(number_of_ho_failed[1]))
# print("percentage of failed handofss = " + str(100*(number_of_ho_failed[0] + number_of_ho_failed[1])/(number_of_ho_attempts[0] + number_of_ho_attempts[1])))
# print("Number of call drops for bstn1 = " + str(number_of_call_drops[0]))
# print("Number of call drops for bstn2 = " + str(number_of_call_drops[1]))

print("\n" + "simulation over")