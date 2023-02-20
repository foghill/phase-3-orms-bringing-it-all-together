class Dog

    attr_accessor :name, :breed, :id

    def initialize(id:nil,name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.all
        sql = <<-SQL
            SELECT * FROM dogs
        SQL
        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    def self.find
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id)[0]
        self.new_from_db(row)
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id)[0]
        self.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
        SQL
        row = DB[:conn].execute(sql, name, breed)[0]
        if row
            dog = self.new_from_db(row)
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name)[0]
        self.new_from_db(row)
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
