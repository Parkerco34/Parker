import pandas as pd
import datetime as da

calender = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 
            'October', 'November', 'December']
today = str(da.date.today())
#today = input('Date (YYYY-MM-DD): ')

def date1():
    last_month = str(int(today[5:7]) - 1)
    if int(last_month) < 10:
        mnth = last_month.replace(last_month, '0' + last_month)
    else:
        mnth = last_month
    year = today[:4]
    month = calender[int(mnth) - 1]
    return mnth, year, month

mnth, year, month = date1()

file_coast = '//gen-filesrv-v01/Manager Trackers/_Final_DTS/DTS_{}_{}_{}_Final.xlsx'.format(year,mnth, month)
file_nrs = '//gen-filesrv-v01/NRS/Reports/Final_DTS/2019 DTS/NRS_DTS_{}_{}_{}_Final.xlsx'.format(year,mnth, month)
file_rms = '//gen-filesrv-v01/RMS/Reports/Final_DTS/RMS_DTS_{}_{}_{}_Final.xlsx'.format(year,mnth, month)
file_epm = '//gen-filesrv-v01/EPM/Reports/Final DTS/DTS_{}_{}_{}_Final EPM.xlsx'.format(year,mnth, month)
file_mids1 = '//gen-filesrv-v01/Mid South/Reports/Final DTS/OC_MIDS_DTS_{}_{}_{}_Final.xlsx'.format(year, mnth, month)
file_mids2 = '//gen-filesrv-v01/Mid South/Reports/Final DTS/NC_MIDS_DTS_{}_{}_{}_Final.xlsx'.format(year, mnth, month)
file_per = '//gen-filesrv-v01/PER/Final DTS/PER DTS Final - {} {}.xlsx'.format(month, year)

files = [file_coast, file_nrs, file_rms, file_epm, file_mids1, file_mids2, file_per]

def process(summare, goalz, payerOne, payerTwo, awgs, feee):
    summary = summare.fillna(0)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    goals = goalz.fillna(0)
    payer1 = payerOne.fillna(0)
    payer2 = payerTwo.fillna(0)
    awg = awgs.fillna(0)
    fee = feee.fillna(0)
    return summary, goals, payer1, payer2, awg, fee

def dts(payer1, payer2, awg, fee):
    dframes = [payer1, payer2, awg, fee]
    dts = pd.concat(dframes, axis=0, ignore_index=True).fillna(0)
    return dts

def coast():
    
    summary, goals, payer1, payer2, awg, fee = process(pd.read_excel(files[0], sheet_name='Summary', sep='\t'),
            pd.read_excel(files[0], sheet_name='Goals', sep='\t', skiprows=[0,1,2,3]),
            pd.read_excel(files[0], sheet_name='RHB1CNT-Credited', sep='\t'),
            pd.read_excel(files[0], sheet_name='RHB2CNT - Credited', sep='\t'),
            pd.read_excel(files[0], sheet_name='AWG - Credited', sep='\t'),
            pd.read_excel(files[0], sheet_name='FRONT(FEE) - Credited', sep='\t')
            )
    
    summ = summary['ID'].drop_duplicates()
    
    payer1['Titanium ID'] = payer1['ZZUT1BORID']
    payer1['ID'] = payer1['ZZUT1USERID']
    payer1['Front Line Fee'] = payer1['Aggregate_11']
    payer1['Company'] = payer1['ZZUH1COMPANY']
    payer1['Data_Point'] = payer1['ZZUT1DATAPOINT']
    payer2['Titanium ID'] = payer2['ZZUT1BORID']
    payer2['ID'] = payer2['ZZUT1USERID']
    payer2['Company'] = payer2['ZZUH1COMPANY']
    payer2['Data_Point'] = payer2['ZZUT1DATAPOINT']
    payer2['Front Line Fee'] = payer2['Aggregate_11']
    awg['Titanium ID'] = awg['ZZUT1BORID']
    awg['ID'] = awg['ZZUT1USERID']
    awg['Front Line Fee'] = awg['Aggregate_11']
    awg['Company'] = awg['ZZUH1COMPANY']
    awg['Data_Point'] = awg['ZZUT1DATAPOINT']
    fee['Titanium ID'] = fee['ZZUT1BORID']
    fee['Front Line Fee'] = fee['Aggregate_11']
    fee['ID'] = fee['ZZUT1USERID']
    fee['Data_Point'] = fee['ZZUT1DATAPOINT']
    fee['Company'] = fee['ZZUH1COMPANY']
    
    dtsC = dts(payer1, payer2, awg, fee).merge(summ, how='inner', on='ID')
    dtsC = dtsC[['Titanium ID', 'ID', 'Data_Point', 'Front Line Fee']]
    performanceC = dtsC.groupby(pd.Grouper('Data_Point')).count().reset_index()
    performanceC = performanceC.drop(['ID'], axis=1)
    dtsC_fee = dtsC.query("Data_Point == 'FRONT'")['Front Line Fee'].sum()
    dtsC_fee = round(dtsC_fee, 4)
    dtsC_fee = pd.Series(dtsC_fee)
    performanceC = pd.concat([performanceC, dtsC_fee], axis=0).fillna(0)
    performanceC = performanceC.drop(3, axis=0)
    performanceC['Fee'] = performanceC[0]
    performanceC = performanceC.drop(0, axis=1)
    performanceC = performanceC.reset_index()
    performanceC = performanceC.drop(['index', 'Front Line Fee'], axis=1)
    performanceC['Data_Point'][3] = 'FRONT'
    
    def employee_coast(fte=[]):
        goals['ID'] = goals['ID'].mask(goals['ID'].isin(goals['Unnamed: 4']),'0')
        goals['ID'] = goals.loc[goals['F/L'] != 0]['ID']
        goals['ID'] = goals['ID'].fillna(0)
    
        for emp in goals.loc[goals['Position'] != 0]['ID']:
            if type(emp) == str and emp.startswith('1'):
                fte.append(emp)
        return len(fte)

    return ('Coast Performance: ', performanceC), ('Employee Count: ', employee_coast())

def nrs():
    
    summary, goals, payer1, payer2, awg, fee = process(pd.read_excel(files[1], sheet_name='Summary', sep='\t', skiprows=[0,1,2,3]),
                                                       pd.read_excel(files[1], sheet_name='Goals', sep='\t', skiprows=[0,1,2]),
                                                       pd.read_excel(files[1], sheet_name='RHB1CNT - Credited', sep='\t'),
                                                       pd.read_excel(files[1], sheet_name='RHB2CNT - Credited', sep='\t'),
                                                       pd.read_excel(files[1], sheet_name='AWG - Credited', sep='\t'),
                                                       pd.read_excel(files[1], sheet_name='Data', sep='\t')
                                                       )
    
    summ = summary['ID'].drop_duplicates()
    
    payer1['Titanium ID'] = payer1['ZZUT1BORID']
    payer1['Data_Point'] = payer1['ZZUT1DATAPOINT']
    payer1['ID'] = payer1['ZZUT1USERID']
    payer2['Titanium ID'] = payer2['ZZUT1BORID']
    payer2['Data_Point'] = payer2['ZZUT1DATAPOINT']
    awg['Titanium ID'] = awg['ZZUT1BORID']
    awg['Data_Point'] = awg['ZZUT1DATAPOINT']
    fee['Titanium ID'] = fee['Borrower_ID']
    fee['ID'] = fee['Collector']

    dts_nrs = dts(payer1, payer2, awg, fee).merge(summ, how='inner', on='ID')
    dts_nrs['Front Line Fee'] = dts_nrs['NRS_Fee']
    dts_nrs = dts_nrs[['Titanium ID', 'Data_Point', 'Front Line Fee']]
    performanceN = dts_nrs.groupby(pd.Grouper('Data_Point')).count().reset_index()
    nrs_fee = fee.loc[fee['Data_Type'] == 'STATS']['NRS_Fee'].sum()
    nrs_fee = round(nrs_fee, 4)
    nrs_fee = pd.Series(nrs_fee)
    performanceN = pd.concat([performanceN, nrs_fee], axis=0).fillna(0)
    performanceN['Fee'] = performanceN[0]
    performanceN = performanceN.drop(1, axis=0)
    performanceN = performanceN.reset_index()
    performanceN = performanceN.drop(['index', 0, 'Front Line Fee'], axis=1)
    performanceN['Data_Point'][3] = 'FRONT'
    
    def employee_countNRS(fte=[]):
        for emp in goals.loc[goals['F/L'] != 0]['ID']:
            if type(emp) == str and emp.startswith('5'):
                fte.append(emp)
        return len(set(fte))

    return ('NRS Performance: ', performanceN), ('Employee Count: ', employee_countNRS())

def rms():    
    
    summary, goals, payer1, payer2, awg, fee = process(pd.read_excel(files[2], sheet_name='Summary', sep='\t', skiprows=[0,1,2,3]),
                                                       pd.read_excel(files[2], sheet_name='Goals', sep='\t', skiprows=[0,1]),
                                                       pd.read_excel(files[2], sheet_name='RHB1CNT - Credited', sep='\t'),
                                                       pd.read_excel(files[2], sheet_name='RHB2CNT - Credited', sep='\t'),
                                                       pd.read_excel(files[2], sheet_name='AWG - Credited', sep='\t'),
                                                       pd.read_excel(files[2], sheet_name='Data', sep='\t')
                                                       )
    
    summ = summary['ID'].drop_duplicates()
    
    payer1['Titanium ID'] = payer1['ZZUT1BORID']
    payer1['Data_Point'] = payer1['ZZUT1DATAPOINT']
    payer1['ID'] = payer1['ZZUT1USERID']
    payer2['Titanium ID'] = payer2['ZZUT1BORID']
    payer2['Data_Point'] = payer2['ZZUT1DATAPOINT']
    awg['Titanium ID'] = awg['ZZUT1BORID']
    awg['Data_Point'] = awg['ZZUT1DATAPOINT']
    fee['Titanium ID'] = fee['Borrower_ID']
    fee['ID'] = fee['Collector']
    
    fee['Front Line Fee'] = fee['RMS_Fee']
    dts_rms = dts(payer1, payer2, awg, fee).merge(summ, how='inner', on='ID')     
    dts_rms = dts_rms[['Titanium ID','Data_Point', 'ID', 'Front Line Fee']]
    performance = dts_rms.groupby(pd.Grouper('Data_Point')).count().reset_index()
    rms_fee = fee.merge(summ, how='inner', on='ID')
    rms_fee = rms_fee.loc[rms_fee['Data_Type'] == 'STATS']['RMS_Fee'].sum()
    rms_fee = pd.Series(rms_fee)
    performanceR = pd.concat([performance, rms_fee], axis=0).fillna(0)
    performanceR = performanceR.drop(1, axis=0)
    performanceR = performanceR.drop('ID', axis=1)
    performanceR = performanceR.reset_index()
    performanceR = performanceR.drop(['index', 'Front Line Fee'], axis=1)
    performanceR['Fee'] = performanceR[0]
    performanceR = performanceR.drop(0, axis=1)
    
    def employee_countRMS(fte=[]):
        for emp in summary.loc[summary['Name'] != 'Total.']['ID']:
            if type(emp) == str and emp.startswith('6'):
                fte.append(emp)
        return len(set(fte))
    
    return ('RMS Performance: ', performanceR), ('Employee Count: ', employee_countRMS())

def epm():
    
    summary, goals, payer1, payer2, awg, fee = process(pd.read_excel(files[3], sheet_name='Summary', sep='\t'),
                                                       pd.read_excel(files[3], sheet_name='Goals', sep='\t', skiprows=[0,1,2,3]),
                                                       pd.read_excel(files[3], sheet_name='RHB1CNT-Credited', sep='\t'),
                                                       pd.read_excel(files[3], sheet_name='RHB2CNT - Credited', sep='\t'),
                                                       pd.read_excel(files[3], sheet_name='AWG - Credited', sep='\t'),
                                                       pd.read_excel(files[3], sheet_name='STATS - Credited', sep='\t')
                                                       )
    
    summ = summary['ID'].drop_duplicates()
    
    payer1['Titanium ID'] = payer1['ZZUT1BORID']
    payer1['Data_Point'] = payer1['ZZUT1DATAPOINT']
    payer1['ID'] = payer1['ZZUT1USERID']
    payer2['Titanium ID'] = payer2['ZZUT1BORID']
    payer2['Data_Point'] = payer2['ZZUT1DATAPOINT']
    awg['Titanium ID'] = awg['ZZUT1BORID']
    awg['Data_Point'] = awg['ZZUT1DATAPOINT']
    fee['Titanium ID'] = fee['Borrower_ID']
    fee['ID'] = fee['Collector']
    
    epm = dts(payer1, payer2, awg, fee).merge(summ, how='inner', on='ID')
    performance = epm.groupby(pd.Grouper('Data_Point')).count().reset_index()
    performance = performance.drop(['ID', 'Company'], axis=1)
    ids = summary['ID']
    mgr = summary['Manager']
    summids = ids[~ids.isin(mgr)]
    epm_fee = fee.merge(summids, how='inner', on='ID')
    epm_fee = epm_fee.loc[epm_fee['Data_Type'] == 'STATS']['Amount'].sum()
    epm_fee = round(epm_fee, 4)*.152
    epm_fee = {'Fee': epm_fee}
    epm_fee = pd.Series(epm_fee)
    performanceE = pd.concat([performance, epm_fee], axis=0).fillna(0)
    performanceE = performanceE.drop(1, axis=0)
    performanceE['Fee'] = performanceE[0]
    performanceE = performanceE.reset_index()
    performanceE = performanceE.drop([0, 'index'],  axis=1)
    performanceE = performanceE[['Data_Point', 'Titanium ID', 'Fee']]
    performanceE['Data_Point'][3] = 'FRONT'
    
    def employee_countEPM(fte=[]):
        goals['ID'] = goals['ID'].mask(goals['ID'].isin(goals['MGR']),'0')
        goals['ID'] = goals.loc[goals['F/L'] != 0]['ID']
        goals['ID'] = goals['ID'].fillna(0)
    
        for emp in goals['ID']:
            if type(emp) == str and emp.startswith('7') and emp != '7NBR' and emp != '7MBC':
                fte.append(emp)
        return len(fte)
    
    return ('EPM Performance: ', performanceE), ('Employee Count: ', employee_countEPM())

def mid_OC():
    summary, goals, payer1, payer2, awg, fee = process(pd.read_excel(files[4], sheet_name='Summary', sep='\t'),
                                                       pd.read_excel(files[4], sheet_name='Goals', sep='\t', skiprows=[0,1,2]),
                                                       pd.read_excel(files[4], sheet_name='RHB1CNT-Credited', sep='\t'),
                                                       pd.read_excel(files[4], sheet_name='RHB2CNT - Credited', sep='\t'),
                                                       pd.read_excel(files[4], sheet_name='AWG - Credited', sep='\t'),
                                                       pd.read_excel(files[4], sheet_name='STATS - Credited', sep='\t')
                                                       )
    
    summ = summary['ID'].drop_duplicates()
    
    payer1['Titanium ID'] = payer1['ZZUT1BORID']
    payer1['Data_Point'] = payer1['ZZUT1DATAPOINT']
    payer1['ID'] = payer1['ZZUT1USERID']
    payer2['Titanium ID'] = payer2['ZZUT1BORID']
    payer2['Data_Point'] = payer2['ZZUT1DATAPOINT']
    awg['Titanium ID'] = awg['ZZUT1BORID']
    awg['Data_Point'] = awg['ZZUT1DATAPOINT']
    fee['Titanium ID'] = fee['Borrower_ID']
    fee['ID'] = fee['Collector']
    
    mid1 = dts(payer1, payer2, awg, fee).merge(summ, how='inner', on='ID')
    mid1 = mid1[['Titanium ID', 'ID', 'Manager', 'Data_Type',  'Data_Point']]
    performanceM1 = mid1.groupby(pd.Grouper('Data_Point')).count().reset_index()
    ids = summary['ID']
    mgr = summary['Manager']
    summids = ids[~ids.isin(mgr)]
    mid1_fee = fee.merge(summids, how='inner', on='ID')
    mid1_fee = mid1_fee.loc[mid1_fee['Data_Type'] == 'STATS']['Amount'].sum()
    mid1_fee = round(mid1_fee, 4)*.152
    mid1_fee = {'Fee': mid1_fee}
    mid1_fee = pd.Series(mid1_fee)
    performanceM1 = pd.concat([performanceM1, mid1_fee], axis=0).fillna(0)
    performanceM1 = performanceM1.drop(['Data_Type', 'ID', 'Manager'], axis=1)
    performanceM1['Front Line Fee'] = performanceM1[0]
    performanceM1['Data_Point'][4] = 'FRONT'
    performanceM1 = performanceM1.drop(0, axis=1)
    performanceM1 = performanceM1.drop(1, axis=0)
    performanceM1 = performanceM1.reset_index()
    performanceM1 = performanceM1.drop('index', axis=1)
    
    def employee_countMID1(fte=[]):
        goals['ID'] = goals['ID'].mask(goals['ID'].isin(goals['MGR']),'0')
        goals['ID'] = goals.loc[goals['F/L'] != 0]['ID']
        goals['ID'] = goals['ID'].fillna(0)
    
        for emp in goals['ID']:
            if type(emp) == str and emp.startswith('9'):
                fte.append(emp)
        return len(fte)
    
    return ('MID_OC Peformance: ', performanceM1), ('Employee Count: ', employee_countMID1())

def mid_NC():
    summary, goals, payer1, payer2, awg, fee = process(pd.read_excel(files[5], sheet_name='Summary', sep='\t'),
                                                       pd.read_excel(files[5], sheet_name='Goals', sep='\t', skiprows=[0]),
                                                       pd.read_excel(files[5], sheet_name='RHB1CNT-Credited', sep='\t'),
                                                       pd.read_excel(files[5], sheet_name='RHB2CNT - Credited', sep='\t'),
                                                       pd.read_excel(files[5], sheet_name='AWG - Credited', sep='\t'),
                                                       pd.read_excel(files[5], sheet_name='STATS - Credited', sep='\t')
                                                       )

    summ = summary['ID'].drop_duplicates()

    payer1['Titanium ID'] = payer1['ZZUT1BORID']
    payer1['Data_Point'] = payer1['ZZUT1DATAPOINT']
    payer1['ID'] = payer1['ZZUT1USERID']
    payer2['Titanium ID'] = payer2['ZZUT1BORID']
    payer2['Data_Point'] = payer2['ZZUT1DATAPOINT']
    awg['Titanium ID'] = awg['ZZUT1BORID']
    awg['Data_Point'] = awg['ZZUT1DATAPOINT']
    fee['Titanium ID'] = fee['Borrower_ID']
    fee['ID'] = fee['Collector']    
    
    mid2 = dts(payer1, payer2, awg, fee).merge(summ, how='inner', on='ID')
    mid2 = mid2[['Titanium ID', 'ID', 'Manager', 'Data_Type',  'Data_Point']]
    performanceM2 = mid2.groupby(pd.Grouper('Data_Point')).count().reset_index()
    ids = summary['ID']
    mgr = summary['Manager']
    summids = ids[~ids.isin(mgr)]
    mid2_fee = fee.merge(summids, how='inner', on='ID')
    mid2_fee = mid2_fee.loc[mid2_fee['Data_Type'] == 'STATS']['Amount'].sum()
    mid2_fee = round(mid2_fee, 4)*.152
    mid2_fee = {'Fee': mid2_fee}
    mid2_fee = pd.Series(mid2_fee)
    performanceM2 = pd.concat([performanceM2, mid2_fee], axis=0).fillna(0)
    performanceM2 = performanceM2.drop(['Data_Type', 'ID', 'Manager'], axis=1)
    performanceM2['Front Line Fee'] = performanceM2[0]
    performanceM2['Data_Point'][4] = 'FRONT'
    performanceM2 = performanceM2.drop(0, axis=1)
    performanceM2 = performanceM2.drop(1, axis=0)
    performanceM2 = performanceM2.reset_index()
    performanceM2 = performanceM2.drop('index', axis=1)
    
    def employee_countMID2(fte=[]):
        goals['ID'] = goals['ID'].mask(goals['ID'].isin(goals['MGR']),'0')
        goals['ID'] = goals.loc[goals['F/L'] != 0]['ID']
        goals['ID'] = goals['ID'].fillna(0)
    
        for emp in goals['ID']:
            if type(emp) == str and emp.startswith('9'):
                fte.append(emp)
        return len(fte)
    
    return ('MID_NC Performance: ', performanceM2), ('Employee Count', employee_countMID2())
    

def per():
    
    summary, goals, payer1, payer2, awg, fee = process(pd.read_excel(files[6], sheet_name='Summary', sep='\t'),
                                                       pd.read_excel(files[6], sheet_name='Goals', sep='\t', skiprows=[0,1,2,3,4]),
                                                       pd.read_excel(files[6], sheet_name='RHB1CNT-Credited', sep='\t'),
                                                       pd.read_excel(files[6], sheet_name='RHB2CNT - Credited', sep='\t'),
                                                       pd.read_excel(files[6], sheet_name='AWG - Credited', sep='\t'),
                                                       pd.read_excel(files[6], sheet_name='STATS - Credited', sep='\t')
                                                       )
    
    summ = summary['ID'].drop_duplicates()
    
    payer1['Titanium ID'] = payer1['ZZUT1BORID']
    payer1['Data_Point'] = payer1['ZZUT1DATAPOINT']
    payer1['ID'] = payer1['ZZUT1USERID']
    payer2['Titanium ID'] = payer2['ZZUT1BORID']
    payer2['Data_Point'] = payer2['ZZUT1DATAPOINT']
    awg['Titanium ID'] = awg['ZZUT1BORID']
    awg['Data_Point'] = awg['ZZUT1DATAPOINT']
    fee['Titanium ID'] = fee['Borrower_ID']
    fee['ID'] = fee['Collector']
    
    per = dts(payer1, payer2, awg, fee).merge(summ, how='inner', on='ID')
    per = per[['Titanium ID', 'ID', 'Data_Point']]
    performanceP = per.groupby(pd.Grouper('Data_Point')).count().reset_index()
    performanceP = performanceP.drop(['ID'], axis=1)
    per_fee = summary['Frontline'][1]
    per_fee = round(per_fee, 4)
    per_fee = {'Fee': per_fee}
    per_fee = pd.Series(per_fee)
    performanceP = pd.concat([performanceP, per_fee], axis=0).fillna(0)
    performanceP['Fee'] = performanceP[0]
    performanceP = performanceP.drop(1, axis=0)
    performanceP = performanceP.reset_index()
    performanceP = performanceP.drop(['index', 0], axis=1)
    performanceP['Data_Point'][3] = 'FRONT'
    
    def employee_countPER(fte=[]):
        for emp in goals.loc[goals['F/L'] != 0]['ID']:
            if type(emp) == str and emp.startswith('8'):
                fte.append(emp)
        return len(set(fte)) - 1  
    
    return ('PER Performance: ', performanceP), ('Employee Count: ', employee_countPER())

print('Coast Performance and Employee Count: ' , coast())
print('NRS Performance and Employee Count: ', nrs())
print('RMS Performance and Employee Count: ',  rms())
print('EPM Performance and Employee Count: ',  epm())
print('MID_OC Performance and Employee Count: ', mid_OC())
print('Performant Performance and Employee Count: ',  per())

################################################################################################################################################
# Competitive Inventory************************************************************************************************************************
# =============================================================================
# lst_inv = '//gen-filesrv-v01/MatthewO/Cory/ED_Inventory_20191017.csv'
# inv = pd.read_csv(lst_inv, sep=',').fillna(0)
# # Competitive Inventory************************************************************************************************************************
# comp_inv = inv.loc[inv['List Date'] > '09/28/2018']
# comp_inv['ID'] = comp_inv['Collector']
# comp_coast = dts.merge(comp_inv, how='inner', on='ID')
# perf = comp_coast.groupby(pd.Grouper('Data_Point')).count()
# 
# 
# # COAST:
# comp_coast = dtsC.merge(comp_inv, how='inner', on='Titanium ID')
# comp_coast = comp_coast[['Titanium ID', 'Data_Point', 'Front Line Fee']]
# performanceComp = comp_coast.groupby(pd.Grouper('Data_Point')).count().reset_index()
# coast_fee = comp_coast['Front Line Fee'].sum()
# coast_fee = round(coast_fee, 4)
# coast_fee = pd.Series(coast_fee)
# performance_comp1 = pd.concat([performanceComp, coast_fee], axis=0).fillna(0)
# performance_comp1 = performance_comp1.drop(['Front Line Fee', 'Company', 'List Date'], axis=1).fillna(0).reset_index()
# performance_comp1 = performance_comp1.drop([0], axis=1)
# performance_comp1 = performance_comp1.drop('index', axis=1)
# performance_comp1['Fee'] = performance_comp1[0]
# performance_comp1 = performance_comp1.drop([0], axis=1)
# performance_comp1['Data_Point'][4] = 'Front'
# =============================================================================


