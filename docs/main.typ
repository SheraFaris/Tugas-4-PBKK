#set document(
  title: "Database Integration: TypeORM vs Prisma",
  author: "SheraFaris",
  date: datetime.today(),
)

#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2cm),
)

#set text(
  font: "New Computer Modern",
  size: 11pt,
)

#set heading(numbering: "1.1")

#align(center)[
  #text(size: 20pt, weight: "bold")[
    Database Integration Implementation
  ]
  
  #text(size: 16pt)[
    TypeORM vs Prisma Comparison
  ]
  
  #v(1em)
  
  #text(size: 12pt)[
    E04 - Database Integration Assignment
  ]
  
  #v(2em)
]

#outline(indent: true)

#pagebreak()

= Introduction

This document details the implementation of a Twitter-like social media application using two different database integration approaches: TypeORM and Prisma. The application features users, posts, and likes with full CRUD operations for both ORM solutions.

= Implementation Steps

== Step 1: Schema Design

The first step was to design the database schema with three main entities:

=== Prisma Schema (`prisma/schema.prisma`)

```prisma
model User {
  id        Int      @id @default(autoincrement())
  name      String
  email     String   @unique
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  posts     Post[]
  likes     Like[]

  @@map("users")
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String
  authorId  Int
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  likes     Like[]

  @@map("posts")
}

model Like {
  id        Int      @id @default(autoincrement())
  userId    Int
  postId    Int
  createdAt DateTime @default(now())
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  post      Post     @relation(fields: [postId], references: [id], onDelete: Cascade)

  @@unique([userId, postId])
  @@map("likes")
}
```

Key features:
- Auto-incrementing IDs for all entities
- Unique constraint on user email
- Timestamps (createdAt, updatedAt) for auditing
- Cascade delete for maintaining referential integrity
- Unique constraint on userId-postId combination to prevent duplicate likes

== Step 2: TypeORM Entity Implementation

TypeORM entities were implemented using decorators to define the database structure:

=== User Entity

```typescript
@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({ unique: true })
  email: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => Post, (post) => post.author)
  posts: Post[];

  @OneToMany(() => Like, (like) => like.user)
  likes: Like[];
}
```

Similar implementations were done for Post and Like entities with appropriate decorators for:
- `@PrimaryGeneratedColumn()` for auto-incrementing IDs
- `@Column()` for regular columns
- `@ManyToOne()` and `@OneToMany()` for relationships
- `@CreateDateColumn()` and `@UpdateDateColumn()` for timestamps
- `@Unique()` for unique constraints

== Step 3: Data Transfer Objects (DTOs)

DTOs were implemented with validation decorators to ensure data integrity:

=== CreateUserDto

```typescript
export class CreateUserDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEmail()
  @IsNotEmpty()
  email: string;
}
```

Similar DTOs were created for:
- CreatePostDto (title, content, authorId)
- CreateLikeDto (userId, postId)
- UpdateDtos extending PartialType for optional fields

== Step 4: Service Layer Implementation

=== TypeORM Services

TypeORM services use the Repository pattern:

```typescript
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async create(createUserDto: CreateUserDto): Promise<User> {
    const user = this.userRepository.create(createUserDto);
    return this.userRepository.save(user);
  }

  async findAll(): Promise<User[]> {
    return this.userRepository.find();
  }

  async findOne(id: number): Promise<User> {
    return this.userRepository.findOne({ where: { id } });
  }

  async update(id: number, updateUserDto: UpdateUserDto): Promise<User> {
    await this.userRepository.update(id, updateUserDto);
    return this.findOne(id);
  }

  async remove(id: number): Promise<void> {
    await this.userRepository.delete(id);
  }
}
```

=== Prisma Services

Prisma services use the PrismaClient directly:

```typescript
@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createUserDto: CreateUserDto) {
    return this.prisma.user.create({
      data: createUserDto,
    });
  }

  async findAll() {
    return this.prisma.user.findMany();
  }

  async findOne(id: number) {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async update(id: number, updateUserDto: UpdateUserDto) {
    return this.prisma.user.update({
      where: { id },
      data: updateUserDto,
    });
  }

  async remove(id: number) {
    return this.prisma.user.delete({
      where: { id },
    });
  }
}
```

== Step 5: Database Migration and Client Generation

=== Prisma
1. Generate Prisma Client: `prisma generate`
2. Create migration: `prisma migrate dev --name init`
3. Apply migration: automatically applied during development

=== TypeORM
- TypeORM synchronizes automatically in development mode using `synchronize: true` option
- In production, migrations should be created manually using TypeORM CLI

== Step 6: Testing

All 31 e2e tests passed successfully:
- TypeORM CRUD operations: 16 tests (Users, Posts, Likes)
- Prisma CRUD operations: 15 tests (Users, Posts, Likes)
- Basic application test: 1 test

Command used: `pnpm test:e2e`

= Comparison: TypeORM vs Prisma

== TypeORM

=== Advantages
1. *Decorator-based approach*: Familiar to developers coming from Java/Spring or .NET
2. *Active Record pattern support*: Can use both Active Record and Data Mapper patterns
3. *Framework agnostic*: Can be used with any Node.js framework
4. *Multiple database support*: Easy to switch between databases
5. *Mature ecosystem*: Been around longer, more established community
6. *Complex queries*: QueryBuilder provides powerful query construction capabilities
7. *Full control*: Direct access to the entity manager and repositories

=== Disadvantages
1. *Decorator overhead*: Requires many decorators, verbose code
2. *Type safety*: Less type-safe compared to Prisma's generated client
3. *Learning curve*: More concepts to learn (repositories, entity managers, query builders)
4. *Migration management*: Manual migration creation can be error-prone
5. *Performance*: Additional abstraction layer can impact performance
6. *N+1 problem*: Easy to accidentally create N+1 queries without careful planning

== Prisma

=== Advantages
1. *Type safety*: Fully type-safe database client generated from schema
2. *Developer experience*: Excellent autocomplete and IntelliSense support
3. *Schema-first approach*: Single source of truth in Prisma schema file
4. *Migration management*: Built-in migration tool with automatic migration generation
5. *Performance*: Optimized queries with minimal overhead
6. *Simplicity*: Cleaner, more intuitive API
7. *Modern tooling*: Prisma Studio for database browsing
8. *Auto-generated documentation*: Schema serves as documentation

=== Disadvantages
1. *Less flexible*: More opinionated, harder to customize
2. *Query limitations*: Some complex queries require raw SQL
3. *Database support*: Limited compared to TypeORM (though covers most use cases)
4. *Bundle size*: Larger client bundle size
5. *Vendor lock-in*: Tightly coupled to Prisma ecosystem
6. *Less established*: Newer technology, smaller community

= Which One Is Better?

== Winner: *Prisma* 🏆

Prisma is the better choice for most modern applications, especially for the following reasons:

=== 1. Superior Type Safety
Prisma's generated client provides compile-time type safety that catches errors before runtime. This is invaluable in large applications where refactoring can be risky.

=== 2. Better Developer Experience
The autocomplete, IntelliSense, and clear API make development faster and more enjoyable. Developers spend less time reading documentation.

=== 3. Declarative Schema
The Prisma schema file is easier to read and understand than scattered TypeORM decorators across multiple entity files. It serves as living documentation.

=== 4. Migration Management
Prisma's automatic migration generation is more reliable and less error-prone than TypeORM's manual migration creation.

=== 5. Performance
Prisma generates optimized queries with minimal overhead, making it faster for most use cases.

=== 6. Modern Architecture
Prisma was designed from the ground up for modern TypeScript applications, whereas TypeORM was influenced by older Java ORMs.

== When to Use TypeORM

Despite Prisma being the better choice overall, TypeORM is preferable in these scenarios:

1. *Legacy projects*: When working with existing TypeORM codebases
2. *Complex queries*: When you need fine-grained control over query generation
3. *Multiple databases*: When you need to support many different database types
4. *Active Record pattern*: When you prefer the Active Record pattern over Data Mapper
5. *Framework requirements*: When working with frameworks that have better TypeORM integration

== Recommendation for This Project

For a Twitter-like social media application with straightforward CRUD operations, *Prisma is the clear winner*. The implementation was:
- Faster to develop
- Easier to maintain
- More type-safe
- Had better performance
- Produced cleaner code

The Prisma service implementations are noticeably more concise and readable compared to their TypeORM counterparts, without sacrificing functionality.

= Conclusion

Both TypeORM and Prisma are excellent ORMs that can handle production workloads. However, Prisma's modern approach, superior type safety, and excellent developer experience make it the better choice for new projects in 2025. TypeORM remains a solid choice for legacy applications or when specific requirements demand its flexibility.

For this assignment, implementing both solutions provided valuable insights into different ORM approaches and their trade-offs. The experience demonstrates that while TypeORM offers more control and flexibility, Prisma's opinionated design leads to faster development and fewer bugs.

#align(center)[
  #v(2em)
  #text(size: 10pt, style: "italic")[
    Documentation completed on #datetime.today().display()
  ]
]
