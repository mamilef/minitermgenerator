
from itertools import product

class MinitermGenerator:
    def __init__(self, predicates):
        self.predicates = predicates

    def generate_miniterms(self):
        terms = [pred.split(' AND ') for pred in self.predicates]
        miniterms = []

        for combination in product(*terms):
            miniterm = {}
            for condition in combination:
                var, value = condition.split('=')
                miniterm[var.strip()] = value.strip()
            miniterms.append(miniterm)

        return miniterms

# Example usage
if __name__ == "__main__":
    predicates = [
        "A=1 AND B=0",
        "A=0 AND C=1",
        "B=1 AND C=0"
    ]
    generator = MinitermGenerator(predicates)
    miniterm_fragments = generator.generate_miniterms()
    for fragment in miniterm_fragments:
        print(fragment)
