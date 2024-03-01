clear
load("HW_week3_data.mat")
%save("HW_week3_data.mat")

figure(1)
clf;

cmap = zeros(size(Y,1),3);
red_ind = find(Y==0);
cmap(red_ind,1) = 1;
blue_ind = find(Y==1);
cmap(blue_ind,3) = 1;

scatter(X(1,:),X(2,:), 10, cmap)

n_h = 4;
num_iterations = 1000;
print_cost = true;
learning_rate = 1.2;
[W1, b1, W2, b2, cost] = nn_model(X, Y, n_h, num_iterations, print_cost, learning_rate);
figure(2)
clf;
plot(cost)
%% Accuracy
[predictions_trainingData, A2] = predict(X, W1, b1, W2, b2);
accuracy = sum(predictions_trainingData == Y)/size(Y,2);


%% Predictions
xx = (min(X(1,:))-1):0.01:(max(X(1,:))+1);
yy = (min(X(2,:))-1):0.01:(max(X(2,:))+1);

[XX, YY] = meshgrid(xx, yy);
X1(1,:) = XX(:);
X1(2,:)=  YY(:);

[predictions, A2] = predict(X1, W1, b1, W2, b2);
cmap = zeros(size(predictions,1),3);
red_ind = find(predictions==0);
cmap(red_ind,1) = 1;
blue_ind = find(predictions==1);
cmap(blue_ind,3) = 1;
%% decision plot
figure(3);clf;
subplot(1,2,1)
scatter(X1(1,:),X1(2,:), 1, cmap)
title(sprintf('Accuracy = %3.1f%%', accuracy*100))
subplot(1,2,2)
scatter(X1(1,:),X1(2,:), 1, A2)
colorbar
%%


function [n_x, n_h, n_y] = layer_sizes(X, Y)
    n_x = size(X,1);
    n_h = 4;
    n_y = size(Y,1);
end

function [n_x, n_y] = layer_sizes_nx_ny(X, Y)
    n_x = size(X,1);
    n_y = size(Y,1);
end

function [W1, b1, W2, b2] = initialize_parameters(n_x, n_h, n_y)
    W1 = randn(n_h, n_x) * 0.01;
    b1 = zeros(n_h, 1);
    W2 = randn(n_y, n_h) * 0.01;
    b2 = zeros(n_y, 1);
end

function [Z1, A1, Z2, A2] = forward_propagation(X, W1, b1, W2, b2)
    Z1 = W1 * X + b1;
    A1 = tanh(Z1);
    Z2 = W2 * A1 + b2;
    A2 = sigmoid(Z2);

end

function cost = compute_cost(A2, Y)
    m = size(Y,1);
    logprobs = log(A2).*Y + (1-Y) .* log(1-A2);
    cost = -1/m .* sum(logprobs);
end

function [dW1, db1, dW2, db2] = backward_propagation(W1, b1, W2, b2, Z1, A1, Z2, A2, X, Y)
    m = size(X, 2) ;
    dZ2 = A2 - Y;
    dW2 = (1/m) .* (dZ2 * A1.');
    db2 = (1/m) .* sum(dZ2,2);
    dZ1 = ((W2.') * dZ2) .* (1 - A1.^2);
    dW1 = (1/m) .* (dZ1 * X.');
    db1 = (1/m) .* sum(dZ1, 2);
end

function [W1, b1, W2, b2] = update_parameters(W1, b1, W2, b2, dW1, db1, dW2, db2, learning_rate)
    W1 = W1 - learning_rate*dW1;
    b1 = b1 - learning_rate*db1;
    W2 = W2 - learning_rate*dW2;
    b2 = b2 - learning_rate*db2;

end

function [W1, b1, W2, b2, cost] = nn_model(X, Y, n_h, num_iterations, print_cost, learning_rate)
    %[n_x, n_h, n_y] = layer_sizes(X, Y); %this line defualts n_h to 4
    [n_x, n_y] = layer_sizes_nx_ny(X, Y);
    [W1, b1, W2, b2] = initialize_parameters(n_x, n_h, n_y);
    cost = zeros(num_iterations,1) ;
    for i = 1:num_iterations
        [Z1, A1, Z2, A2] = forward_propagation(X, W1, b1, W2, b2);
        cost(i) = compute_cost(A2, Y);
        [dW1, db1, dW2, db2] = backward_propagation(W1, b1, W2, b2, Z1, A1, Z2, A2, X, Y);
        [W1, b1, W2, b2] = update_parameters(W1, b1, W2, b2, dW1, db1, dW2, db2, learning_rate);
     end
end

function [predictions, A2] = predict(X, W1, b1, W2, b2)
     [Z1, A1, Z2, A2] = forward_propagation(X, W1, b1, W2, b2);
     predictions = (A2 > 0.5);
end
