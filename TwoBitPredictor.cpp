#include <iostream>
#include <vector>
#include <fstream>
#include <sstream>
#include <cstdint>

using namespace std;

class TwoBitPredictor {
private:
    vector<uint8_t> table;
    size_t size;

    size_t index(uint64_t address) const {
        return (address >> 2) % size;
    }

public:
    TwoBitPredictor(size_t tableSize = 1024) : size(tableSize) {
        table.resize(size, 2); // Weakly Taken
    }

    bool predict(uint64_t address) const {
        uint8_t state = table[index(address)];
        return state >= 2;
    }

    void update(uint64_t address, bool taken) {
        uint8_t &state = table[index(address)];

        if (taken) {
            if (state < 3) state++;
        } else {
            if (state > 0) state--;
        }
    }
};

struct Branch {
    uint64_t address;
    bool taken;
};

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cout << "Usage: " << argv[0] << " <trace_file>" << endl;
        return 1;
    }

    string folder = "traces/";
    string filename = argv[1];
    string fullPath = folder + filename;

    ifstream file(fullPath);
    if (!file) {
        cout << "Error: Could not open file." << endl;
        return 1;
    }

    vector<Branch> trace;
    string line;

    // Read file
    while (getline(file, line)) {
        stringstream ss(line);
        string addrStr;
        int takenInt;

        ss >> addrStr >> takenInt;

        uint64_t address = stoull(addrStr, nullptr, 16);
        bool taken = (takenInt == 1);

        trace.push_back({address, taken});
    }

    file.close();

    TwoBitPredictor predictor(1024);

    int correct = 0;
    int total = 0;

    for (const auto& branch : trace) {
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