from __future__ import print_function
import argparse
import torch
import torch.utils.data
from torch import nn, optim
from torch.autograd import Variable
from torch.nn import functional as F
from torchvision import datasets, transforms
from torchvision.utils import save_image

from datetime import datetime

parser = argparse.ArgumentParser(description='VAE MNIST Example')
parser.add_argument('--batch-size', type=int, default=128, metavar='N',
                    help='input batch size for training (default: 128)')
parser.add_argument('--epochs', type=int, default=10, metavar='N',
                    help='number of epochs to train (default: 10)')
parser.add_argument('--no-cuda', action='store_true', default=False,
                    help='enables CUDA training')
parser.add_argument('--seed', type=int, default=1, metavar='S',
                    help='random seed (default: 1)')
parser.add_argument('--log-interval', type=int, default=10, metavar='N',
                    help='how many batches to wait before logging training status')
parser.add_argument('--model', type=int, default=0,
                    help='model id')
parser.add_argument('--lr', type=float, default=1e-3,
                    help='lr for Adam')
args = parser.parse_args()
args.cuda = not args.no_cuda and torch.cuda.is_available()


torch.manual_seed(args.seed)
if args.cuda:
    torch.cuda.manual_seed(args.seed)


kwargs = {'num_workers': 8, 'pin_memory': True} if args.cuda else {}
train_loader = torch.utils.data.DataLoader(
    datasets.MNIST('../data', train=True, download=True,
                   transform=transforms.ToTensor()),
    batch_size=args.batch_size, shuffle=True, **kwargs)
test_loader = torch.utils.data.DataLoader(
    datasets.MNIST('../data', train=False, transform=transforms.ToTensor()),
    batch_size=args.batch_size, shuffle=True, **kwargs)


class VAE(nn.Module):

    def __init__(self):
        super(VAE, self).__init__()

    def reparameterize(self, mu, logvar):
        if self.training:
          std = logvar.mul(0.5).exp_()
          eps = Variable(std.data.new(std.size()).normal_())
          return eps.mul(std).add_(mu)
        else:
          return mu

    def view_input(self, x):
        return x.view(-1, 784)

    def forward(self, x):
        mu, logvar = self.encode(self.view_input(x))
        z = self.reparameterize(mu, logvar)
        return self.decode(z), mu, logvar


class VAE0(VAE):
    def __init__(self):
        super(VAE0, self).__init__()

        self.fc1 = nn.Linear(784, 400)
        self.fc21 = nn.Linear(400, 20)
        self.fc22 = nn.Linear(400, 20)
        self.fc3 = nn.Linear(20, 400)
        self.fc4 = nn.Linear(400, 784)

        self.relu = nn.ReLU()
        self.sigmoid = nn.Sigmoid()

    def encode(self, x):
        h1 = self.relu(self.fc1(x))
        return self.fc21(h1), self.fc22(h1)

    def decode(self, z):
        h3 = self.relu(self.fc3(z))
        return self.sigmoid(self.fc4(h3))


class VAE1(VAE):
    def __init__(self):
        super(VAE1, self).__init__()

        self.fc1 = nn.Linear(784, 400)
        self.fc1b = nn.Linear(400, 400)
        self.fc21 = nn.Linear(400, 20)
        self.fc22 = nn.Linear(400, 20)
        self.fc3 = nn.Linear(20, 400)
        self.fc3b = nn.Linear(400, 400)
        self.fc4 = nn.Linear(400, 784)

        self.relu = nn.ReLU()
        self.sigmoid = nn.Sigmoid()

    def encode(self, x):
        h1 = self.relu(self.fc1(x))
        h1 = self.relu(self.fc1b(h1))
        return self.fc21(h1), self.fc22(h1)

    def decode(self, z):
        h3 = self.relu(self.fc3(z))
        h3 = self.relu(self.fc3b(h3))
        return self.sigmoid(self.fc4(h3))


class VAE_tanh(VAE):
    def __init__(self):
        super(VAE_tan4, self).__init__()

        self.fc1 = nn.Linear(784, 400)
        self.fc1b = nn.Linear(400, 400)
        self.fc21 = nn.Linear(400, 20)
        self.fc22 = nn.Linear(400, 20)
        self.fc3 = nn.Linear(20, 400)
        self.fc3b = nn.Linear(400, 400)
        self.fc4 = nn.Linear(400, 784)

        self.relu = nn.ReLU()
        self.sigmoid = nn.Sigmoid()
        self.tanh = nn.Tanh()

    def encode(self, x):
        h1 = self.tanh(self.fc1(x))
        h1 = self.tanh(self.fc1b(h1))
        return self.fc21(h1), self.fc22(h1)

    def decode(self, z):
        h3 = self.tanh(self.fc3(z))
        h3 = self.tanh(self.fc3b(h3))
        return self.sigmoid(self.fc4(h3))


class LenetVAE(VAE):
    def __init__(self):

        super(LenetVAE, self).__init__()

        self.conv11 = nn.Conv2d(1, 10, kernel_size=5)
        self.conv12 = nn.Conv2d(10, 20, kernel_size=5)
        self.fc11 = nn.Linear(320, 20)
        self.fc12 = nn.Linear(320, 20)

        self.fc22 = nn.Linear(20, 320)
        self.conv21 = nn.Conv2d(20, 10, kernel_size=5)
        self.conv22 = nn.Conv2d(10, 1, kernel_size=5)

    def encode(self, x):
        print(x.size())
        x = F.tanh(F.max_pool2d(self.conv11(x), 2))
        print(x.size())
        x = F.tanh(F.max_pool2d(self.conv12(x), 2))
        x = x.view(-1, 320)
        print(x.size())
        return self.fc11(x), self.fc12(x)

    def decode(self, z):
        z = F.tanh(self.fc22(z))
        print(z.size())
        z = z.view(-1, 20, 4, 4)
        print(z.size())
        z = F.tanh(F.max_pool2d(self.conv21(z), 2))
        z = F.sigmoid(F.max_pool2d(self.conv22(z), 2))
        z = z.view(-1, 784)
        return z

    def view_input(self, x):
        return x


models = {
 0: VAE0,
 1: VAE1,
 2: VAE_tanh
}

model = models[args.model]()
if args.cuda:
    model.cuda()


def loss_function(recon_x, x, mu, logvar):
    BCE = F.binary_cross_entropy(recon_x, x.view(-1, 784))

    # see Appendix B from VAE paper:
    # Kingma and Welling. Auto-Encoding Variational Bayes. ICLR, 2014
    # https://arxiv.org/abs/1312.6114
    # 0.5 * sum(1 + log(sigma^2) - mu^2 - sigma^2)
    KLD = -0.5 * torch.sum(1 + logvar - mu.pow(2) - logvar.exp())
    # Normalise by same number of elements as in reconstruction
    KLD /= args.batch_size * 784

    return BCE + KLD


optimizer = optim.Adam(model.parameters(), lr=args.lr)


def train(epoch):
    model.train()
    train_loss = 0
    for batch_idx, (data, _) in enumerate(train_loader):
        data = Variable(data)
        if args.cuda:
            data = data.cuda()
        optimizer.zero_grad()
        recon_batch, mu, logvar = model(data)
        loss = loss_function(recon_batch, data, mu, logvar)
        loss.backward()
        train_loss += loss.data.item()
        optimizer.step()
        if batch_idx % args.log_interval == 0:
            print('Train Epoch: {} [{}/{} ({:.0f}%)]\tLoss: {:.6f}'.format(
                epoch, batch_idx * len(data), len(train_loader.dataset),
                100. * batch_idx / len(train_loader),
                loss.data.item() / len(data)))

    print('====> Epoch: {} Average loss: {:.4f}'.format(
          epoch, train_loss / len(train_loader.dataset)))


def test(epoch):
    model.eval()
    test_loss = 0
    for i, (data, _) in enumerate(test_loader):
        if args.cuda:
            data = data.cuda()
        data = Variable(data, volatile=True)
        recon_batch, mu, logvar = model(data)
        test_loss += loss_function(recon_batch, data, mu, logvar).data.item()
        if i == 0:
          n = min(data.size(0), 8)
          comparison = torch.cat([data[:n],
                                  recon_batch.view(args.batch_size, 1, 28, 28)[:n]])
          save_image(comparison.data.cpu(),
                     'results/reconstruction_' + str(epoch) + '.png', nrow=n)

    test_loss /= len(test_loader.dataset)
    print('====> Test set loss: {:.4f}'.format(test_loss))


start = datetime.now()

for epoch in range(1, args.epochs + 1):
    beg = datetime.now()
    train(epoch)
    print("@ %s / %s" % (str(datetime.now()-start), str(datetime.now()-beg)))
    test(epoch)
    sample = Variable(torch.randn(64, 20))
    if args.cuda:
       sample = sample.cuda()
    sample = model.decode(sample).cpu()
    save_image(sample.data.view(64, 1, 28, 28),
               'results/sample_' + str(epoch) + '.png')
