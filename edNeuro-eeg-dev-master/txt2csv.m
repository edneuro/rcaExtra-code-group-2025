function [] = txt2csv(txtfile,csvfile)
    data = importdata(txtfile);
    csvwrite(csvfile,data.data);
end