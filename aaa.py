def generate_data(rows, columns):
    data = [[f'{i:02X}{j:02X}' for j in range(1, columns + 1)] for i in range(1, rows + 1)]
    return data

def save_to_file(data, filename):
    with open(filename, 'w') as file:
        for row in data:
            file.write(' '.join(row) + '\n')

if __name__ == "__main__":
    rows = 8
    columns = 64
    filename = 'haha.txt'

    generated_data = generate_data(rows, columns)
    save_to_file(generated_data, filename)
