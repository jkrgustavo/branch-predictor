#include <iostream>
#include <vector>
#include <fstream>
#include <sstream>
#include <cstdint>

using namespace std;

class OneBitPredictor {
private:
    vector<bool> table;
    size_t size;

    size_t index(uint64_t address) const {
        return (address >> 2) % size;
    }

public:
    OneBitPredictor(size_t tableSize = 1024) : size(tableSize) {
        table.resize(size, true); // initialize to "taken"
    }

    bool predict(uint64_t address) const {
        return table[index(address)];
    }

    void update(uint64_t address, bool taken) {
        table[index(address)] = taken;
    }
};

struct Branch {
    uint64_t address;
    bool taken;
};

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <trace_file>" << endl;
        return 1;
    }

    ifstream file(argv[1]);
    if (!file) {
        cerr << "Error: Could not open file." << endl;
        return 1;
    }

    vector<Branch> trace;
    string line;

    // Read trace file
    while (getline(file, line)) {
        stringstream ss(line);
        string addrStr;
        int takenInt;

        ss >> addrStr >> takenInt;

        uint64_t address = stoull(addrStr, nullptr, 16);
        bool taken = (takenInt == 1);

        Branch b;
        b.address = address;
        b.taken = taken;

        trace.push_back(b);
    }

    file.close();

    OneBitPredictor predictor(1024);

    int correct = 0;
    int total = 0;

    for (size_t i = 0; i < trace.size(); i++) {
        const Branch& branch = trace[i];

        bool prediction = predictor.predict(branch.address);

        if (prediction == branch.taken) {
            correct++;
        }

        predictor.update(branch.address, branch.taken);
        total++;
    }

    cout << "Total: " << total << endl;
    cout << "Correct: " << correct << endl;
    cout << "Accuracy: "
         << (100.0 * correct / total) << "%" << endl;

    return 0;
}